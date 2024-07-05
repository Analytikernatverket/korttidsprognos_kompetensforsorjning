ftrafikljus_texter <- function(df, titel_txt) {
  
  library(tidyverse)
  
  match_utveckling_var <- df %>% pull(match_utveckling)
  lone_utveckling_var <- df %>% pull(lone_utveckling)
  utbuds_utveckling_var <- df %>% pull(utbuds_utveckling)
  efterfrage_utveckling_var <- df %>% pull(efterfrage_utveckling)
  
  
  # Läs in diagramtexterna
  dfdia_texter <- readxl::read_excel("./Konfiguration/styrfil.xlsx", sheet="Diagramtexter") %>% 
    janitor::clean_names() %>% 
    rename(match_utveckling = matchning, lone_utveckling = reallon, 
           utbuds_utveckling = utbud, efterfrage_utveckling = sammanlagd_efterfraga)
  
  # Filtrera ut den text som matchar diagramrubriken och parametrarna på indikaorn
  if (titel_txt == "Matchningseffekt") {
    txt_diagram <- filter(dfdia_texter, diagram == titel_txt, match_utveckling == match_utveckling_var)[, c(1, 2, 7)]
  } else if (titel_txt == "Reallöneutveckling") {
    txt_diagram <- filter(dfdia_texter, diagram == titel_txt, lone_utveckling == lone_utveckling_var)[, c(1, 2, 7)]
  } else if (titel_txt == "Utbudseffekt") {
    txt_diagram <- filter(dfdia_texter, diagram == titel_txt, utbuds_utveckling == utbuds_utveckling_var)[, c(1, 2, 7)]
  } else if (titel_txt == "Sammanlagd efterfrågeeffekt") {
    txt_diagram <- filter(dfdia_texter, diagram == titel_txt, match_utveckling == match_utveckling_var & lone_utveckling == lone_utveckling_var )[, c(1, 2, 7)]
  } else if (titel_txt == "Arbetsmarknadens utveckling") {
    txt_diagram <- filter(dfdia_texter, diagram == titel_txt, utbuds_utveckling == utbuds_utveckling_var & efterfrage_utveckling == efterfrage_utveckling_var )[, c(1, 2, 7)]
  }
  

  return(txt_diagram)
  
}

# ftrafikljus_texter(df = dfind_trafikljus2[1, ], "Sammanlagd efterfrågeeffekt")

