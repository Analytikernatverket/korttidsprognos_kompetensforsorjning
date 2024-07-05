fskapa_dia <- function(geo_omrade = "Nordvästra Skåne", sun_grp = "Övrig gymnasial utbildning inom teknik och tillverkning") {
  
  
  # geo_omrade = "Nordvästra Skåne"; sun_grp = "Övrig gymnasial utbildning inom teknik och tillverkning"
  
  # Flödesdiagram
  
  dfflode_dia <- dfflode %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp) %>%
    fskapa_flodesdiagram(title_txt = "Utbudsflöde")
  
  # Matchningsdiagram
  
  dfmatch <- dfind_trafikljus2 %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp)
  
  dfmatch <-  ftrafikljus_texter(dfmatch, titel_txt = "Matchningseffekt")
  
  dfmatch_dia <- ftrafikljusdia2(dfmatch)
  
  match_txt <- dfmatch$text
  
  # Reallöneutvecklingsdiagram
  
 dfreallon <- dfind_trafikljus2 %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp) %>% 
    ftrafikljus_texter(titel_txt = "Reallöneutveckling")
  
  dfreallon_utv_dia <- ftrafikljusdia2(dfreallon)
  
  reallon_txt <- dfreallon$text
  
 
  # Utbudsdiagram
  
  dfutbud <- dfind_trafikljus2 %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp) %>% 
    ftrafikljus_texter(titel_txt = "Utbudseffekt")
  
  dfutbud_dia <- ftrafikljusdia2(dfutbud)
  
  utbud_txt <- dfutbud$text
  
   # Arbetsmarknadens utveckling-diagram
  
  dfarbm_utv <- dfind_trafikljus2 %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp) %>%
    ftrafikljus_texter(titel_txt = "Arbetsmarknadens utveckling")
  
  dfarbm_utv_dia <- ftrafikljusdia2(dfarbm_utv)
  
  arbm_utv_txt <- dfarbm_utv$text
  
  
  # Efterfrågans utveckling-diagram

  dfefterfr_eff <- dfind_trafikljus2 %>% 
    filter(regiondel_namn == geo_omrade, sun_ruap_grp_namn == sun_grp) %>% 
    ftrafikljus_texter(titel_txt = "Sammanlagd efterfrågeeffekt")
  
  dfefterfr_eff_dia <- ftrafikljusdia2(dfefterfr_eff)
  
  efterfrage_eff_txt <- dfefterfr_eff$text
  
  
  return(list(geo_omrade = geo_omrade,
              sum_grp = sun_grp,
              dfflode_dia = dfflode_dia,
              dfmatch_dia = dfmatch_dia,
              dfreallon_utv_dia = dfreallon_utv_dia,
              dfutbud_dia = dfutbud_dia,
              dfarbm_utv_dia = dfarbm_utv_dia,
              dfefterfr_eff_dia = dfefterfr_eff_dia,
              match_txt = match_txt,
              reallon_txt = reallon_txt,
              utbud_txt = utbud_txt,
              arbm_utv_txt = arbm_utv_txt,
              efterfrage_eff_txt = efterfrage_eff_txt
              
  ))
  
}

# dftmp <- fskapa_dia(geo_omrade = "Nordvästra Skåne", sun_grp = "Övrig gymnasial utbildning inom teknik och tillverkning") 
  
  