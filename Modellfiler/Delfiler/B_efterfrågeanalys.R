print("---------------------- Efterfrågeprognosen! -------------------------")
starttid <- Sys.time()
library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

source("./Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')
forstaObsAr <- basArSkattning -5

con <- DBI::dbConnect(odbc::odbc(), 
                      driver = "ODBC Driver 17 for SQL Server", 
                      server = "monasql.micro.intra", 
                      database = "P0927",  
                      Trusted_Connection = "yes", 
                      bigint = "numeric", 
                      encoding = "windows-1252")

#lägger upp kommungrupper i SQL-databasen
dbWriteTable(con,"tmp_kommungrupper", kommunGrupper, overwrite = TRUE)

dfRelativMedianink<- dbGetQuery(con,"
                                  select distinct
                                  	t1.ar,
                                  	t1.Regiondel_namn,
                                  	t1.Sun2000GrpJust,
                                  	PERCENTILE_CONT(0.5)
                                  		WITHIN GROUP(ORDER BY t1.ForvErs)
                                  		OVER (PARTITION BY t1.Ar, t1.Regiondel_namn)
                                  	as regiondelMedianInk,
                                  	PERCENTILE_CONT(0.5)
                                  		WITHIN GROUP(ORDER BY t1.ForvErs)
                                  		OVER (PARTITION BY t1.Ar, t1.Regiondel_namn, t1.Sun2000GrpJust)
                                  	as regiondelUtbMedianInk
                                  from
                                  	(
                                  		select
                                  			t1.ar,
                                  			t2.Regiondel_namn,
                                  			t1.ForvErs,
                                  			t3.Sun2000GrpJust
                                  		from
                                  			P0927.KP_stativ t1
                                  			inner join P0927.tmp_kommungrupper t2
                                  				on t1.Kommun=t2.Kommun
											                    INNER JOIN P0927.KP_utbTillhorighet t3 ON t1.P0927_LopNr_PersonNr = t3.P0927_LopNr_PersonNr AND t1.ar = t3.ar
                                  		where
                                  			t2.Regiondel_namn != 'Övriga Sverige'
                                  			and t1.SyssStat ='1'
                                  			and t1.alder between 20 and 66
                                  			and t1.ar>2014
                                  	) t1
                                ") %>%
  mutate(relativLon=regiondelUtbMedianInk/regiondelMedianInk)


dfRelativMedianinkDiff <- dfRelativMedianink %>%
  arrange(Regiondel_namn, Sun2000GrpJust, ar) %>%
  filter(ar == basArSkattning | ar==forstaObsAr) %>%
  group_by(Regiondel_namn, Sun2000GrpJust) %>%
  mutate(relLoneUtv = log(relativLon) - log(lag(relativLon, n=1))) %>%
  filter(ar==basArSkattning) %>%
  arrange(Regiondel_namn, desc(relLoneUtv)) %>%
  ungroup()

dfMatchningsandel <- dbGetQuery(con, "
                                  select
                                  	t1.ar,
                                  	t1.Regiondel_namn,
                                  	t1.Sun2000GrpJust,
                                  	t1.match,
                                  	t1.antal as antalMatchade,
                                  	t2.antal,
                                  	cast(t1.antal as float)/t2.antal as matchadForvarvsgrad
                                  from 
                                  	(
                                  		select
                                  			t1.ar,
                                  			t2.[Regiondel_namn],
											                  t4.Sun2000GrpJust,
                                  			t3.match_20 as match,
                                  			count(*) as antal
                                  		from 
                                  			[P0927].tmp_kommungrupper t2,
                                  			[P0927].KP_stativ t1
                  											left join P0927.KP_utbTillhorighet t4
                  												on t1.[P0927_LopNr_PersonNr]=t4.[P0927_LopNr_PersonNr] and t1.ar=t4.ar 
                                  			left join P0927.KP_Match_20 t3
                                  				on t1.[P0927_LopNr_PersonNr]=t3.[P0927_LopNr_PersonNr] and t1.ar=t3.ar
                                  		where
                                  			t1.ar>2015
                                  			and t1.alder between 20 and 66
                                  			and t2.Kommun = t1.Kommun
                                  			and t2.Regiondel_namn !='Övriga Sverige'
                                  			and t3.Match_20 not in ('98', '96', '99')
                                  		group by
                                  			t1.ar,
                                  			t2.[Regiondel_namn],
											                  t4.Sun2000GrpJust,
                                  			t3.match_20
                                  	) t1,
                                  	(
                                  		select
                                  			t1.ar,
                                  			t2.[Regiondel_namn],
											                  Sun2000GrpJust,
                                  			count(*) as antal
                                  		from 
                                  			[P0927].tmp_kommungrupper t2,
                                  			[P0927].KP_stativ t1
                  											left join P0927.KP_utbTillhorighet t4
                  												on t1.[P0927_LopNr_PersonNr]=t4.[P0927_LopNr_PersonNr] and t1.ar=t4.ar 
                                  			left join P0927.KP_Match_20 t3
                                  				on t1.[P0927_LopNr_PersonNr]=t3.[P0927_LopNr_PersonNr] and t1.ar=t3.ar
                                  		where
                                  			t1.ar>2015
                                  			and t1.alder between 20 and 66
                                  			and t2.Kommun = t1.Kommun
                                  			and t2.Regiondel_namn !='Övriga Sverige'
                                  			and t3.Match_20 not in ('98', '96', '99')
                                  		group by
                                  			t1.ar,
                                  			t2.[Regiondel_namn],
											                  t4.Sun2000GrpJust
                                  	) t2
                                  	where
                                  		t1.ar=t2.ar
                                  		and t1.[Regiondel_namn]= t2.Regiondel_namn
                                  		and t1.Sun2000GrpJust=t2.Sun2000GrpJust
                                  		and t1.match ='22'                                ")

dfDiffMatchningsandel <- dfMatchningsandel %>%
  arrange(Regiondel_namn, Sun2000GrpJust, ar) %>%
  filter(ar == sistObsAr | ar==forstaObsAr) %>%
  group_by(Regiondel_namn, Sun2000GrpJust) %>%
  mutate(relMartchUtv = log(matchadForvarvsgrad) - log(lag(matchadForvarvsgrad, n=1))) %>%
  filter(ar==sistObsAr) %>%
  arrange(Regiondel_namn, desc(relMartchUtv)) %>% 
  select(-ar, -match) %>%
  ungroup()

dfEfterfraga <- dfRelativMedianinkDiff %>%
  left_join(dfDiffMatchningsandel, by=c("Regiondel_namn"="Regiondel_namn", "Sun2000GrpJust"="Sun2000GrpJust"))

wbEfterfraganExport <-  createWorkbook()
addWorksheet(wbEfterfraganExport, "Efterfraga")
writeData(wbEfterfraganExport, sheet="Efterfraga", x=dfEfterfraga)
saveWorkbook(wbEfterfraganExport,"./tmpFiler/ResultatEfterfrågeprognos.xlsx", overwrite = TRUE)

#Rensar upp i data
dbRemoveTable(con,"tmp_kommungrupper")
rm(aldersGrupp, con, dfDiffMatchningsandel, dfEfterfraga, dfMatchningsandel, dfRelativMedianink)
rm(dfRelativMedianinkDiff, dfUtbildningsgrupper, dfUtbildningsgrupperNyckel, kommunGrupper, sunRuapGrpNamn)
rm(antalUtbGrp, basArSkattning, forstaObsAr, maxAlder, minAlder, minAntalIUtbGrp)
rm(prognosperiod, sistObsAr, skattningsperiod, wbEfterfraganExport, PGUtbud, PGMatchning, PGRelativlon)

sluttid <- Sys.time()
kortid <- difftime(sluttid, starttid, units = "secs")
kortid_efterfragan <- sprintf("%02d:%02d:%02d",
                         as.integer(kortid) %/% 3600,
                         (as.integer(kortid) %% 3600) %/% 60,
                         as.integer(kortid) %% 60
)
print(cat("Körtiden för efterfrågeprognosen är: ", kortid_efterfragan))
rm(kortid, sluttid, starttid)
