print("---------------------- Sätter poäng för sammanvägning av prognoserna! -------------------------")
starttid <- Sys.time()
library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

#Läser in prognosresultatet
source(".//Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')
dfUtbudprognosTotalt <- read.xlsx("./tmpFiler/ResultatUtbudsprognos.xlsx", sheet="PrognosTotalt")
dfEfterfrågeprognos <- read.xlsx("./tmpFiler/ResultatEfterfrågeprognos.xlsx", sheet="Efterfraga")
#dfUtbAggregat <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet ="utbildningsgrupper")

slutAr <- as.numeric(format(Sys.Date(), "%Y")) - 1 + prognosperiod

 
dfUtbudsprognosPoang <- dfUtbudprognosTotalt %>%  
  mutate(relativDiffUtbud = procentDiffTotal-pctDiffTotalt) %>%
  mutate(utbudsUtveckling = case_when(relativDiffUtbud > pctDiffTotalt+PGUtbud ~ -2,
                                      relativDiffUtbud < pctDiffTotalt-PGUtbud ~  2,
                                      TRUE ~0))
  
dfEfterfrågeprognosExport <- dfEfterfrågeprognos %>%
  mutate(loneUtveckling = case_when(relLoneUtv > PGRelativlon ~ 1,
                                  relLoneUtv < -PGRelativlon ~ -1,
                                  TRUE ~ 0 )) %>%
  mutate(matchUtveckling = case_when(relMartchUtv > PGMatchning ~ 1,
                                     relMartchUtv < -PGMatchning ~ -1,
                                     TRUE ~0)) %>%
  mutate(arbetsmarknadsSituation=loneUtveckling+matchUtveckling) %>%
  arrange(Regiondel_namn, desc(arbetsmarknadsSituation)) %>%
  select(-ar)

wbPoang <- createWorkbook()
addWorksheet(wbPoang, "utbud")
addWorksheet(wbPoang, "efterfragan")
writeData(wbPoang, sheet="utbud", x=dfUtbudsprognosPoang)
writeData(wbPoang, sheet="efterfragan", x=dfEfterfrågeprognosExport)
saveWorkbook(wbPoang, "./tmpFiler/poang.xlsx", overwrite = TRUE)

#Rensa upp bland variabler.
rm(aldersGrupp, dfEfterfrågeprognos, dfEfterfrågeprognosExport, dfUtbildningsgrupper, dfUtbildningsgrupperNyckel)
rm(dfUtbudprognosTotalt, dfUtbudsprognosPoang, kommunGrupper, sunRuapGrpNamn)
rm(antalUtbGrp, basArSkattning, maxAlder, minAlder, minAntalIUtbGrp, PGMatchning, PGRelativlon, PGUtbud)
rm(prognosperiod, sistObsAr, skattningsperiod, slutAr, wbPoang)


#Beräknar körtiden
sluttid <- Sys.time()
kortid <- difftime(sluttid, starttid, units = "secs")
kortid_poang <- sprintf("%02d:%02d:%02d",
                         as.integer(kortid) %/% 3600,
                         (as.integer(kortid) %% 3600) %/% 60,
                         as.integer(kortid) %% 60
)
print(cat("Körtiden den sammansatta poängen är: ", kortid_poang))
rm(kortid, sluttid, starttid)
