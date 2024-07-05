print("---------------------- Rapporttabellen skapas! -------------------------")
starttid <- Sys.time()
library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

#Läser in prognosresultatet
source(".//Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')
dfutbudArAlder <- read.xlsx("./tmpFiler/ResultatUtbudsprognos.xlsx", sheet="PrognosData")

slutAr <- as.numeric(format(Sys.Date(), "%Y")) - 1 + prognosperiod

dfUtbgrp <- dfUtbildningsgrupper %>%
  left_join(dfUtbildningsgrupperNyckel, by="utbildningsgrupp")

dfUtbudPoang <- read.xlsx("./tmpFiler/poang.xlsx", sheet="utbud")
dfEFterfraganPoang <- read.xlsx("./tmpFiler/poang.xlsx", sheet="efterfragan")
dfPrognosPoang <- dfUtbudPoang %>%
  left_join(dfEFterfraganPoang, by=c("regiondelNamn"="Regiondel_namn", "sunRuapGrp"="Sun2000GrpJust"))

dfresultatPrognos <- dfPrognosPoang %>%
  left_join(dfUtbgrp, by=c("sunRuapGrp"="Sun2000GrpJust")) %>%
  select(regiondelNamn,
         sunRuapGrp,
         sunRuapGrpNamn,
         utbildningsgrupp,
         utbildningsgruppTxt,
         inTotalt,
         utAlder,
         utflyttade,
         vidareutbildade,
         inAlder,
         inflyttade,
         examinerade,
         utTotalt,
         procentDiffTotal,
         relativDiffUtbud,
         matchadForvarvsgrad,
         relMartchUtv,
         matchUtveckling,
         loneUtveckling,
         utbudsUtveckling,
         arbetsmarknadsSituation) %>%
  rename(diffPctUtbud=procentDiffTotal,
         diffRelativtUtbud=relativDiffUtbud,
         relMatchUtv=relMartchUtv,
         efterfrageUtveckling=arbetsmarknadsSituation
  ) %>%
  mutate(totalPrognosPoang=efterfrageUtveckling+utbudsUtveckling) %>%
  arrange(regiondelNamn, -totalPrognosPoang) %>%
  drop_na(inTotalt)

#Begränsar resultatet till max antal utbildningar per delregion eller utbildningar med mer än en undre gräns av antal.
dfresultatPrognos <- dfresultatPrognos  %>%
  group_by(regiondelNamn) %>%
  slice_max(order_by=inTotalt, n=antalUtbGrp) %>%
  ungroup()

dfresultatPrognos <- dfresultatPrognos %>%
  filter(inTotalt >= minAntalIUtbGrp)

prognosWb <- createWorkbook()
addWorksheet(prognosWb, "Nordvästra Skåne")
addWorksheet(prognosWb, "Sydvästra Skåne")
addWorksheet(prognosWb, "Nordöstra Skåne")
addWorksheet(prognosWb, "Sydöstra Skåne")
addWorksheet(prognosWb, "Gymnasial utbildning")
addWorksheet(prognosWb, "Pedagogik och lärarutbildning")
addWorksheet(prognosWb, "Hälso- och sjukvård samt ...")
addWorksheet(prognosWb, "Teknik, naturvetenskap och data")
addWorksheet(prognosWb, "Humaniora, samhällsvetenskap...")
addWorksheet(prognosWb, "Samtliga regiondelar")
writeData(prognosWb, sheet="Nordvästra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Nordvästra Skåne"))
writeData(prognosWb, sheet="Sydvästra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Sydvästra Skåne"))
writeData(prognosWb, sheet="Nordöstra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Nordöstra Skåne"))
writeData(prognosWb, sheet="Sydöstra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Sydöstra Skåne"))
writeData(prognosWb, sheet="Gymnasial utbildning", x=dfresultatPrognos %>% filter(utbildningsgrupp=="G"))
writeData(prognosWb, sheet="Pedagogik och lärarutbildning", x=dfresultatPrognos %>% filter(utbildningsgrupp=="L"))
writeData(prognosWb, sheet="Hälso- och sjukvård samt ...", x=dfresultatPrognos %>% filter(utbildningsgrupp=="S"))
writeData(prognosWb, sheet="Teknik, naturvetenskap och data", x=dfresultatPrognos %>% filter(utbildningsgrupp=="N"))
writeData(prognosWb, sheet="Humaniora, samhällsvetenskap...", x=dfresultatPrognos %>% filter(utbildningsgrupp=="H"))
writeData(prognosWb, sheet="Samtliga regiondelar", x=dfresultatPrognos)
saveWorkbook(prognosWb, "./Resultatfiler/prognosresultat.xlsx", overwrite = TRUE)

wbHelaPrognos <- createWorkbook()
addWorksheet(wbHelaPrognos, "Hela utbprog med år och ålder")
writeData(wbHelaPrognos, sheet="Hela utbprog med år och ålder", x=dfutbudArAlder)
saveWorkbook(wbHelaPrognos, "./Resultatfiler/prognosresultat_år_och_ålder.xlsx", overwrite = TRUE)

#Rensarupp i df och variabler
rm(aldersGrupp, dfEFterfraganPoang, dfPrognosPoang, dfresultatPrognos, dfUtbgrp, dfUtbildningsgrupper, dfUtbildningsgrupperNyckel)
rm(dfutbudArAlder, dfUtbudPoang, kommunGrupper, sunRuapGrpNamn, wbHelaPrognos)
rm(antalUtbGrp, basArSkattning, maxAlder, minAlder, PGMatchning, PGRelativlon, PGUtbud, prognosperiod, prognosWb)
rm(minAntalIUtbGrp, sistObsAr, skattningsperiod, slutAr)

sluttid <- Sys.time()
kortid <- difftime(sluttid, starttid, units = "secs")
kortid_rapport <- sprintf("%02d:%02d:%02d",
                              as.integer(kortid) %/% 3600,
                              (as.integer(kortid) %% 3600) %/% 60,
                              as.integer(kortid) %% 60
)
print(cat("Körtiden skrivandet av rapporttabell är: ", kortid_rapport))
rm(kortid, sluttid, starttid)