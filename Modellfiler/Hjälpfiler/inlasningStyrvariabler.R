# Sista observerade året, ar1.
conStyr <- DBI::dbConnect(odbc::odbc(), 
                      driver = "ODBC Driver 17 for SQL Server", 
                      server = "monasql.micro.intra", 
                      database = "P0927",  
                      Trusted_Connection = "yes", 
                      bigint = "numeric", 
                      encoding = "windows-1252")

dfSistObsAr <- dbGetQuery(conStyr,"select max(ar2) asMaxar from P0927.KP_IndataFlode")
sistObsAr <- dfSistObsAr[1,]


# Läser in styrvariablerna.
kommunGrupper <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "omraden") %>%
  mutate(Regiondel_namn=case_when(is.na(Regiondel_namn) ~ "Övriga Sverige",
                                  TRUE ~ Regiondel_namn))
dfUtbildningsgrupper <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "utbildningsgrupper")
dfUtbildningsgrupperNyckel <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "utbildningsgrupperNycklar")
styrVariabler <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "styrVariabler")
prognosperiod <- styrVariabler[1,2]
skattningsperiod <- styrVariabler[2,2]
basArSkattning <- styrVariabler[3,2]
basArSkattning <- ifelse(is.na(basArSkattning), sistObsAr, basArSkattning)
maxAlder <- styrVariabler[4,2]
minAlder <- styrVariabler[5,2]
antalUtbGrp <- styrVariabler[6,2]
antalUtbGrp <- ifelse(is.na(antalUtbGrp),999,antalUtbGrp)
minAntalIUtbGrp <- styrVariabler[7,2]
minAntalIUtbGrp <- ifelse(is.na(minAntalIUtbGrp),0, minAntalIUtbGrp)
PGUtbud <- styrVariabler[8,2]
PGRelativlon <- styrVariabler[8,2]
PGMatchning <- styrVariabler[8,2]


aldersGrupp <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "aldersGrupp") %>%
  mutate(aldersGrupp = paste(as.character(fran), "-")) %>%
  mutate(aldersGrupp = paste(aldersGrupp,as.character(till)))

sunRuapGrpNamn <- read.xlsx("./Konfiguration/styrfil.xlsx", sheet = "utbildningskoder")

rm(dfSistObsAr, styrVariabler, conStyr)

         