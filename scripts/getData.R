library(vroom)
library(dplyr)
library(janitor)
library(jsonlite)


executeQuery <- function(cube, dds, mms) {
  dm <- "https://api.datamexico.org/tesseract/data.jsonrecords"
  meas <- "measures="
  drill <- "drilldowns="
  dm_url <- paste0(dm, "?cube=", cube, "&",
                   drill, paste(dds, collapse = "%2C"), "&",
                   meas,  paste(mms, collapse = "%2C"), "&locale=es")


  resp <- jsonlite::fromJSON(txt = dm_url)

  resp$data %>%
    janitor::clean_names() %>%
    as_tibble()
}

cube <- "anuies_enrollment"
dds <- c("State", "Municipality", "Area", "Academic+Degree", "Institution",  "Field", "Sex")
mms <- c("Students")

executeQuery(cube, dds, mms) %>% vroom_write("../data/anuies.tsv")

cube <- "health_establishments"
dds <- c("State", "Municipality", "Areas", "CLUES", "Establishment+Type",  "Institution")
mms <- c("Clinics", "Beds")

executeQuery(cube, dds, mms)  %>% vroom_write("../data/hospitales.tsv")

cube <- "inegi_denue&Year=2018%2C2019%2C2020%2C2021"
dds <- c("State", "Municipality", "Sector", "Subsector", "Industry+Group",  "Year")
mms <- c("Companies")

executeQuery(cube, dds, mms)  %>% vroom_write("data/industrias.tsv")


temp <- tempfile()
download.file("https://www.inegi.org.mx/contenidos/programas/ccpv/2020/datosabiertos/iter/iter_00_cpv2020_csv.zip",
              temp)
# Seleccionar solamente las variables demográficas
poblacion_demo <- vroom::vroom(unz(temp, "iter_00_cpv2020/conjunto_de_datos/conjunto_de_datos_iter_00CSV20.csv"),
                               col_select = c(ENTIDAD, NOM_ENT, MUN, NOM_MUN, LOC, NOM_LOC,
                                              POBTOT, POBFEM, POB0_14, POB15_64, POB65_MAS))
unlink(temp)
poblacion_demo <- poblacion_demo %>%
  filter(NOM_LOC == "Total del Municipio") %>%
  select(-LOC, -NOM_LOC)

poblacion_demo %>% vroom_write("../data/poblacion.tsv")
