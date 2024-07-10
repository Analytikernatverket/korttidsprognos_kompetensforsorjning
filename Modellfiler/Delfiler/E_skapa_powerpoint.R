print("---------------------- Skapar powerpoints! -------------------------")
starttid_pptx <- Sys.time()
library(tidyverse)
library(scales)
library(units)
library(ggtext)
library(officer)
#Install janitor

source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/theme_skane_mod.R", encoding = "utf-8")
source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/fskapa_flodesdiagram.R", encoding = "utf-8")
source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/ftrafikljus_texter.R", encoding = "utf-8")
source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/ftrafikljusdia2.R", encoding = "utf-8")
source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/fskapa_dia.R", encoding = "utf-8")

#Läser in lista med samtliga geografiska områden/regiondelar som har prognos.
dfIn <- readxl::read_excel("./Resultatfiler/Prognosresultat.xlsx", sheet = "Samtliga regiondelar") %>%
  arrange(regiondelNamn, utbildningsgrupp, sunRuapGrp)

dfRegiondelar <- dfIn %>%
  distinct(regiondelNamn)

for (rad in 1:nrow(dfRegiondelar)) {
  region <- dfRegiondelar$regiondelNamn[rad]
  print(region)
  filnamn_pp <- paste0("./Resultatfiler/",region, ".pptx")

  # Ange vilken flik i prognosresultatfilen som ska läsas in
  df <- dfIn %>% 
    janitor::clean_names() %>% 
    mutate(match_utveckling = as.integer(match_utveckling),
           lone_utveckling = as.integer(lone_utveckling),
           utbuds_utveckling = as.integer(utbuds_utveckling),
           total_prognos_poang = as.integer(total_prognos_poang),
           efterfrage_utveckling = as.integer(efterfrage_utveckling))
  df <- df %>%
    filter(regiondel_namn==region)
  # Levels och labels för flödesdata
  levels_utb_flode <- rev(c("netto", "inflyttade", "in_alder", "examinerad", "vidareutbildade", "utflyttade", "ut_alder"))
  labels_utb_flode <- rev(c("netto", "inflyttade", "åldersinträde 20-åringar", "examinerade", "vidareutbildade", "utflyttade", "pensionärer"))
  # Delar upp prognosresultatfilen i två dataframes: 1 för flödesdata och 1 för trafikljusdiagram
  dfflode <- df %>% 
    select(regiondel_namn, sun_ruap_grp_namn, vidareutbildade, utflyttade, in_alder, examinerade, inflyttade, ut_alder) %>% 
    mutate(utflyttade = utflyttade * -1,
           ut_alder = ut_alder * -1) %>% 
    mutate(netto = inflyttade + examinerade + in_alder + vidareutbildade + utflyttade + ut_alder) %>% 
    pivot_longer(cols = c(netto, inflyttade, in_alder, examinerade, vidareutbildade, utflyttade, ut_alder), names_to = "kategori", values_to = "antal") %>% 
    mutate(kategori = factor(kategori, levels = levels_utb_flode, labels = labels_utb_flode),
           pos_neg = antal >= 0)
  
  
  dfind_trafikljus2 <- df %>% 
    select(regiondel_namn,  sun_ruap_grp, sun_ruap_grp_namn, match_utveckling,
           lone_utveckling, utbuds_utveckling, total_prognos_poang, efterfrage_utveckling)
  # Skapa en dataframe med geografinamn och utbildningsnamn som det går att loopa sig igenom med purrr
  dfgeo_utb <- df %>% 
    select(regiondel_namn, sun_ruap_grp_namn)
  
  # Lagra alla text och diagram i en listvariabel
  lkortprogn <- purrr::map2(.x = dfgeo_utb$regiondel_namn, .y = dfgeo_utb$sun_ruap_grp_namn, ~fskapa_dia(geo_omrade = .x, sun_grp = .y), .progress = TRUE)
  # Kolla vad de olika fälten i powerpointmallen heter
  # read_pptx("mall_utbildningsprognos.potx") %>%
  #   officer::layout_properties()
  # Läs in pp-mallen och spar i variabeln my_pres
  my_pres <- read_pptx("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/mall_utbildningsprognos.potx") %>% 
    remove_slide(index = 1)
  
  # Loop för att generera sida efter sida i powerpoint. Varje iteration lägger till en ny bild
  for (i in 1:length(lkortprogn)){
  
  lista <- lkortprogn[[i]]
  
  print(paste("Skapar bild", i , "av", length(lkortprogn), "för", region))
  
  my_pres <- my_pres %>% 
    add_slide(layout = "prognospresentation", master = "Region Skåne presentation") %>% 
    ph_with(value = str_glue("{lista$geo_omrade}: {lista$sum_grp}"), location = ph_location_label(ph_label = "utbildningsrubrik")) %>% 
    ph_with(value = lista$dfflode_dia, location = ph_location_label(ph_label = "dia_flode")) %>% 
    ph_with(value = lista$dfarbm_utv_dia, location = ph_location_label(ph_label = "dia_arbetsm_utv")) %>% 
    ph_with(value = lista$dfmatch_dia, location = ph_location_label(ph_label = "dia_match")) %>% 
    ph_with(value = lista$dfreallon_utv_dia, location = ph_location_label(ph_label = "dia_reallon")) %>% 
    ph_with(value = lista$dfefterfr_eff_dia, location = ph_location_label(ph_label = "did_efterfragan")) %>% 
    ph_with(value = lista$dfutbud_dia, location = ph_location_label(ph_label = "dia_utbud")) %>% 
    ph_with(value = lista$match_txt, location = ph_location_label(ph_label = "dia_match_txt")) %>%
    ph_with(value = lista$reallon_txt, location = ph_location_label(ph_label = "dia_reallon_txt")) %>%
    ph_with(value = lista$efterfrage_eff_txt, location = ph_location_label(ph_label = "dia_efterfragan_txt")) %>%
    ph_with(value = lista$utbud_txt, location = ph_location_label(ph_label = "dia_utbud_txt")) %>% 
    ph_with(value = lista$arbm_utv_txt, location = ph_location_label(ph_label = "dia_arbm_utv_txt"))
  }

    my_pres <- my_pres %>% 
    remove_slide(index = 1)

  # Spara powerpointfilen
  print(my_pres, filnamn_pp)
}



## Rensar upp bland filer och variabler
rm(df, dfflode, dfIn, dfgeo_utb, dfind_trafikljus2, dfRegiondelar, lista, my_pres, lkortprogn)
rm(filnamn_pp, labels_utb_flode, levels_utb_flode, rad, region, skala_karta_dubbel, skala_karta_enkel, skala_linje_farg, skala_stapel_farg)
rm(fcolour_ramp, fskapa_dia, fskapa_flodesdiagram, ftrafikljus_texter, ftrafikljusdia2, theme_skane, theme_Skane_karta)
rm(i)

sluttid_pptx <- Sys.time()
kortid <- difftime(sluttid_pptx, starttid_pptx, units = "secs")
kortid_pptx <- sprintf("%02d:%02d:%02d",
                          as.integer(kortid) %/% 3600,
                          (as.integer(kortid) %% 3600) %/% 60,
                          as.integer(kortid) %% 60
)

print(cat("Körtiden den sammansatta poängen är: ", kortid_pptx))
rm(sluttid_pptx, kortid, starttid_pptx)

