print("---------------------- Utbudsprognosen! -------------------------")
starttid_utbud <- Sys.time()
library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

#Läser in styrkodsimporten
source(".//Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')

#Bestämmer årtalen för skattning.
startAr <- as.numeric(format(Sys.Date(), "%Y")) - 1
slutAr <- startAr + 1 + skattningsperiod

#Öppnar kontakt med Stativ
con <- DBI::dbConnect(odbc::odbc(), 
                      driver = "ODBC Driver 17 for SQL Server", 
                      server = "monasql.micro.intra", 
                      database = "P0927",  
                      Trusted_Connection = "yes", 
                      bigint = "numeric", 
                      encoding = "windows-1252")

#lägger upp kommungrupper i SQL-databasen
dbWriteTable(con,"tmp_kommungrupper", kommunGrupper, overwrite = TRUE)

#Hämtar populationen
dfPopulation <- dbGetQuery(con,"
                                select
                                	t1.ar2 as ar,
                                	t2.Regiondel_namn as regiondelNamn,
                                	t1.sunRuapGrp2 as sunRuapGrp,
                                	t1.alder2 as alder,
                                	count(*) as inTotalt
                                FROM
                                	P0927.KP_IndataFlode t1,
									                [P0927].[tmp_kommungrupper] t2
                                where
                                	t1.alder2 between 20 and 68
                					         and t1.kommun2=t2.kommun
                                group by
                                	t1.ar2,
                                	t2.Regiondel_namn,
                                	t1.sunRuapGrp2,
                                	t1.alder2
                                order by
                                	ar,
                                	regiondelNamn,
                                	sunRuapGrp,
                                	alder
                      ")
#Läser in koefficienterna
dfKoefficienter <- read.xlsx("./Konfiguration/koefficienter.xlsx", sheet = "Koefficienter") 
dfSyssGrad <- read.xlsx("./Konfiguration/koefficienter.xlsx", sheet = "syssGrad")

#Skapar inputfil för tjugoåringar
dfTjugoaringarUtb <- read.xlsx("./Konfiguration/koefficienter.xlsx", sheet = "AldersIntrade") 

dfTjugoaringar <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "Befolkningsprognos") %>%
  left_join(kommunGrupper, by=c("kommun"="Kommun_namn")) %>%
  select(Ar, Regiondel_namn, antal)  %>%
  group_by(Ar, Regiondel_namn) %>%
  summarise(Totalt = sum(antal)) %>%
  ungroup() %>%
  left_join(dfTjugoaringarUtb, by=c("Regiondel_namn"="regiondelNamn"), relationship = "many-to-many") %>%
  mutate(inAlder=Totalt*mAldersIntrade, alder=20) %>%
  rename(regiondelNamn=Regiondel_namn, ar=Ar) %>%
  select(ar, regiondelNamn, sunRuapGrp, alder, inAlder)

#Förbereder indata till prognosen
dfPrognosGrundfil <- dfPopulation %>%
  filter(ar==basArSkattning) %>%
  mutate(inAlder = 0)

if(exists("dfPrognosData")) {
  rm(dfPrognosData)
}
itAr <- basArSkattning+1

#Prognossnurran
while (itAr < slutAr) {
print(itAr)
  dfPrognosGrundfil <- dfPrognosGrundfil %>%
    mutate(ar=ar+1,
           alder=alder+1) %>%
    filter(alder <= maxAlder+1)
  dfInAlder <- dfTjugoaringar %>%
    filter(ar==itAr) %>%
    mutate(inTotalt=0) %>%
    select(ar, regiondelNamn, sunRuapGrp, alder, inTotalt, inAlder)
  dfPrognosGrundfil <- rbind(dfPrognosGrundfil, dfInAlder)
  dfPrognosGrundfil <- dfPrognosGrundfil %>%
    mutate(utAlder=ifelse(alder==maxAlder+1, inTotalt, 0))   

  dfPrognosGrundfil <- dfPrognosGrundfil %>%
    left_join(dfKoefficienter, by=c("regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "alder"="alder"), relationship = "many-to-many")  %>%
    mutate(utflyttade=ifelse(!is.na(kUtflyttade), kUtflyttade*inTotalt, 0),
           vidareutbildade=ifelse(!is.na(kVidareutbildade),kVidareutbildade*inTotalt,0),
           examinerade=ifelse(!is.na(kExaminerade),kExaminerade*inTotalt,0),
           inflyttade=ifelse(!is.na(kInflyttade),kInflyttade*inTotalt,0),
           utTotalt=inTotalt+inflyttade+examinerade+inAlder-utflyttade-vidareutbildade-utAlder
           ) %>%
    select(ar, regiondelNamn, sunRuapGrp, alder, inTotalt, utAlder, utflyttade, vidareutbildade, inAlder, inflyttade, examinerade, utTotalt)

  
  if(!exists("dfPrognosData")) {
    dfPrognosData <- data.frame(ar = numeric(0),
                                regiondelNamn = character(0),
                                sunRuapGrp = character(0),
                                alder = numeric(0),
                                inTotalt = numeric(0),
                                utAlder = numeric(0),
                                utflyttade = numeric(0),
                                vidareutbildade = numeric(0),
                                inAlder = numeric(0),
                                inflyttade = numeric(0),
                                examinerade = numeric(0),
                                utTotalt = numeric(0)
                                )
  }
    dfPrognosData <- rbind(dfPrognosData, dfPrognosGrundfil)

itAr <- itAr + 1
dfPrognosGrundfil <- dfPrognosGrundfil %>%
  mutate(inTotalt=utTotalt,
         inAlder=0) %>%
  select(ar, regiondelNamn, sunRuapGrp, alder, inTotalt, inAlder)
}

# Efterarbete

dfPrognosData <- dfPrognosData %>%
  left_join(dfSyssGrad, by=c("regiondelNamn"="regiondelNamn", "sunRuapGrp" ="sunRuapGrp", "alder"="alder"), relationship = "many-to-many") %>%
  left_join(sunRuapGrpNamn, by=c("sunRuapGrp"="sunRuapGrp")) %>%
  mutate(utSyss=syssGrad*utTotalt,
         alder1=alder-1)%>%
  select(alder1, ar, regiondelNamn, sunRuapGrp, sunRuapGrpNamn, alder, inTotalt, utAlder, utflyttade, vidareutbildade, inAlder, inflyttade, examinerade, utTotalt, utSyss)

dfPrognosData <- dfPrognosData %>%
  left_join(dfSyssGrad, by=c("regiondelNamn"="regiondelNamn", "sunRuapGrp" ="sunRuapGrp", "alder1"="alder"), relationship = "many-to-many") %>%  
  mutate(inSyss=syssGrad*inTotalt,)%>%
  select(ar, regiondelNamn, sunRuapGrp, sunRuapGrpNamn, alder, inTotalt, inSyss, utAlder, utflyttade, vidareutbildade, inAlder, inflyttade, examinerade, utTotalt, utSyss) %>%
  arrange(regiondelNamn, sunRuapGrp, ar, alder)


dfKorttidsPrognosAggregat <- dfPrognosData %>%
  group_by(ar, regiondelNamn, sunRuapGrp, sunRuapGrpNamn) %>%
  summarise(inTotalt=sum(as.integer(round(inTotalt))),
            inSyss=sum(ifelse(is.na(inSyss),0,as.integer(round(inSyss)))),
            utAlder=sum(as.integer(round(utAlder))),
            utflyttade=sum(as.integer(round(utflyttade))),
            vidareutbildade=sum(as.integer(round(vidareutbildade))),
            inAlder=sum(as.integer(round(inAlder))),
            inflyttade=sum(as.integer(round(inflyttade))),
            examinerade=sum(as.integer(round(examinerade))),
            utTotalt=sum(as.integer(round(utTotalt))),
            utSyss=sum(ifelse(is.na(utSyss),0,as.integer(round(utSyss))))
            ) %>%
  ungroup() %>%
  mutate(diff=utTotalt-inTotalt,
         syssDiff=utSyss-inSyss) %>%
  arrange(regiondelNamn, sunRuapGrp, ar)

#Summerar till hela prognosperioden
dfutbudsPrognosUtb <- dfKorttidsPrognosAggregat %>%
  filter(ar >= startAr & ar <= slutAr & regiondelNamn != 'Övriga Sverige') %>%
  arrange(regiondelNamn, sunRuapGrp, ar) %>%
  group_by(regiondelNamn, sunRuapGrp, sunRuapGrpNamn) %>%
  summarise(inTotalt = first(inTotalt),
            inSyss = first(inSyss),
            utTotalt = last(utTotalt),
            utSyss = last(utSyss),
            utAlder = sum(utAlder),
            utflyttade = sum(utflyttade),
            vidareutbildade = sum(vidareutbildade),
            inAlder = sum(inAlder),
            inflyttade = sum(inflyttade),
            examinerade = sum(examinerade)
  ) %>%
  mutate(prognosStart = startAr+1,
         prognosSlut = slutAr) %>%
  mutate(procentDiffTotal=log(utTotalt/inTotalt)) %>%
  ungroup()

#Beräknar nettoflödet för hela arbertsmarknaden
dfutbudsPrognosTotalt <- dfutbudsPrognosUtb %>%
  group_by(regiondelNamn) %>%
  summarise(sumInTotalt=sum(inTotalt),
            sumUtTotalt=sum(utTotalt)) %>%
  mutate(pctDiffTotalt = log(sumUtTotalt/sumInTotalt)) %>%
  ungroup()

dfUtbudsPrognosExport <- dfutbudsPrognosUtb %>%
  inner_join(dfutbudsPrognosTotalt, by="regiondelNamn")

#Skriver resultat till excel
wb <- createWorkbook()
addWorksheet(wb, "PrognosTotalt")
writeData(wb, sheet="PrognosTotalt", x=dfUtbudsPrognosExport)
addWorksheet(wb, "KorttidsPrognosAggregat")
writeData(wb, sheet="KorttidsPrognosAggregat", x=dfKorttidsPrognosAggregat)
addWorksheet(wb, "PrognosData")
writeData(wb, sheet="PrognosData", x=dfPrognosData)
saveWorkbook(wb, "./tmpFiler/ResultatUtbudsprognos.xlsx", overwrite = TRUE)

#Rensar upp i tabeller och variabler
dbRemoveTable(con,"tmp_kommungrupper")
rm(aldersGrupp)
rm(kommunGrupper)
rm(dfInAlder)
rm(dfPrognosGrundfil)
rm(dfSyssGrad)
rm(dfTjugoaringar)
rm(dfTjugoaringarUtb)
rm(dfPopulation)
rm(dfKoefficienter)
rm(con)
rm(basArSkattning)
rm(itAr)
rm(maxAlder)
rm(prognosperiod)
rm(sistObsAr)
rm(skattningsperiod)
rm(slutAr)
rm(wb)
rm(dfKorttidsPrognosAggregat)
rm(dfPrognosData)
rm(sunRuapGrpNamn)
rm(minAlder)
rm(antalUtbGrp, minAntalIUtbGrp)
rm(dfUtbildningsgrupper, dfUtbildningsgrupperNyckel, PGUtbud)
rm(dfUtbudsPrognosExport, dfutbudsPrognosTotalt, dfutbudsPrognosUtb)
rm(PGMatchning, PGRelativlon, startAr)


sluttid_utbud <- Sys.time()
kortid_u <- difftime(sluttid_utbud, starttid_utbud, units = "secs")
kortid_utbud <- sprintf("%02d:%02d:%02d",
                              as.integer(kortid_u) %/% 3600,
                              (as.integer(kortid_u) %% 3600) %/% 60,
                              as.integer(kortid_u) %% 60
)
print(cat("Körtiden för utbudsprognosen är: ", kortid_utbud))
rm(kortid_u, sluttid_utbud, starttid_utbud)

