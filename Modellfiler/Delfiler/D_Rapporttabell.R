print("---------------------- Rapporttabellen skapas! -------------------------")
starttid <- Sys.time()
library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

#Läser in prognosresultatet
source(".//Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')
source(".//Modellfiler/Delfiler/D_RapportHjälpfiler/funktioner.R")
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
#Testar med att göra begränsningen i utskriften för att inte begränsa redovisning efter utbildning.
#BÖR DISKUTERAS VILKET SOM ÄR BÄST
#dfresultatPrognos <- dfresultatPrognos  %>%
#  group_by(regiondelNamn) %>%
#  slice_max(order_by=inTotalt, n=antalUtbGrp) %>%
#  ungroup() %>%
#  filter(inTotalt >= minAntalIUtbGrp)

#Testa om ovan med filter på slutet fungerar.
#dfresultatPrognos <- dfresultatPrognos %>%
#  filter(inTotalt >= minAntalIUtbGrp)

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
writeData(prognosWb, sheet="Nordvästra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Nordvästra Skåne") %>% arrange(utbildningsgrupp, sunRuapGrp) %>% slice_max(order_by=inTotalt, n=antalUtbGrp) %>% filter(inTotalt >= minAntalIUtbGrp))
writeData(prognosWb, sheet="Sydvästra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Sydvästra Skåne") %>% arrange(utbildningsgrupp, sunRuapGrp) %>% slice_max(order_by=inTotalt, n=antalUtbGrp) %>% filter(inTotalt >= minAntalIUtbGrp))
writeData(prognosWb, sheet="Nordöstra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Nordöstra Skåne") %>% arrange(utbildningsgrupp, sunRuapGrp) %>% slice_max(order_by=inTotalt, n=antalUtbGrp) %>% filter(inTotalt >= minAntalIUtbGrp))
writeData(prognosWb, sheet="Sydöstra Skåne", x=dfresultatPrognos %>% filter(regiondelNamn=="Sydöstra Skåne") %>% arrange(utbildningsgrupp, sunRuapGrp) %>% slice_max(order_by=inTotalt, n=antalUtbGrp) %>% filter(inTotalt >= minAntalIUtbGrp))
writeData(prognosWb, sheet="Gymnasial utbildning", x=dfresultatPrognos %>% filter(utbildningsgrupp=="G") %>% arrange(sunRuapGrp, regiondelNamn))
writeData(prognosWb, sheet="Pedagogik och lärarutbildning", x=dfresultatPrognos %>% filter(utbildningsgrupp=="L") %>% arrange(sunRuapGrp, regiondelNamn))
writeData(prognosWb, sheet="Hälso- och sjukvård samt ...", x=dfresultatPrognos %>% filter(utbildningsgrupp=="S") %>% arrange(sunRuapGrp, regiondelNamn))
writeData(prognosWb, sheet="Teknik, naturvetenskap och data", x=dfresultatPrognos %>% filter(utbildningsgrupp=="N") %>% arrange(sunRuapGrp, regiondelNamn))
writeData(prognosWb, sheet="Humaniora, samhällsvetenskap...", x=dfresultatPrognos %>% filter(utbildningsgrupp=="H") %>% arrange(sunRuapGrp, regiondelNamn))
writeData(prognosWb, sheet="Samtliga regiondelar", x=dfresultatPrognos %>% slice_max(order_by=inTotalt, n=antalUtbGrp) %>% filter(inTotalt >= minAntalIUtbGrp))
formatCellXLSX(workbook=prognosWb, flik="Nordvästra Skåne", df=dfresultatPrognos %>% filter(regiondelNamn=="Nordvästra Skåne"))
formatCellXLSX(workbook=prognosWb, flik="Sydvästra Skåne", df=dfresultatPrognos %>% filter(regiondelNamn=="Sydvästra Skåne"))
formatCellXLSX(workbook=prognosWb, flik="Nordöstra Skåne", df=dfresultatPrognos %>% filter(regiondelNamn=="Nordöstra Skåne"))
formatCellXLSX(workbook=prognosWb, flik="Sydöstra Skåne", df=dfresultatPrognos %>% filter(regiondelNamn=="Sydöstra Skåne"))
formatCellXLSX(workbook=prognosWb, flik="Gymnasial utbildning", df=dfresultatPrognos %>% filter(utbildningsgrupp=="G"))
formatCellXLSX(workbook=prognosWb, flik="Pedagogik och lärarutbildning", df=dfresultatPrognos %>% filter(utbildningsgrupp=="L"))
formatCellXLSX(workbook=prognosWb, flik="Hälso- och sjukvård samt ...", df=dfresultatPrognos %>% filter(utbildningsgrupp=="S"))
formatCellXLSX(workbook=prognosWb, flik="Teknik, naturvetenskap och data", df=dfresultatPrognos %>% filter(utbildningsgrupp=="N"))
formatCellXLSX(workbook=prognosWb, flik="Humaniora, samhällsvetenskap...", df=dfresultatPrognos %>% filter(utbildningsgrupp=="H"))
formatCellXLSX(workbook=prognosWb, flik="Samtliga regiondelar", df=dfresultatPrognos)
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
rm(formatCellXLSX)

sluttid <- Sys.time()
kortid <- difftime(sluttid, starttid, units = "secs")
kortid_rapport <- sprintf("%02d:%02d:%02d",
                              as.integer(kortid) %/% 3600,
                              (as.integer(kortid) %% 3600) %/% 60,
                              as.integer(kortid) %% 60
)
print(cat("Körtiden skrivandet av rapporttabell är: ", kortid_rapport))
rm(kortid, sluttid, starttid)
