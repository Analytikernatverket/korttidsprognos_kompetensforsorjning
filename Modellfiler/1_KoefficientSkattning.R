library(DBI)
library(tidyverse)
library(openxlsx)
library(sqldf)

#Läser in styrkodsimporten
source(".//Modellfiler/Hjälpfiler/inlasningStyrvariabler.R", encoding = 'UTF-8')

#Bestämmer årtalen för skattning.
maxAr <- basArSkattning
minAr <- basArSkattning - skattningsperiod + 1

#Hämtar data från SQL-databasen.
con <- DBI::dbConnect(odbc::odbc(), 
                      driver = "ODBC Driver 17 for SQL Server", 
                      server = "monasql.micro.intra", 
                      database = "P0927",  
                      Trusted_Connection = "yes", 
                      bigint = "numeric", 
                      encoding = "windows-1252")

#lägger upp kommungrupper i SQL-databasen
dbWriteTable(con,"tmp_kommungrupper", kommunGrupper, overwrite = TRUE)

#Hämtar grunddata för koefficientberärkning.

Koefficienter <- dbGetQuery(con,"
                                select
                                	t1.ar2 as ar,
                                	t2.Regiondel_namn as regiondelNamn,
                                	t1.sunRuapGrp1 as sunRuapGrp,
                                	t1.alder2 as alder,
                                	count(*) as inTotalt
                                FROM
                                	P0927.KP_IndataFlode t1,
                                	P0927.tmp_kommungrupper t2
                                where
                                	t1.alder2 between 21 and 68
                                	and t1.kommun1=t2.kommun
                                group by
                                	t1.ar2,
                                	t2.Regiondel_namn,
                                	t1.sunRuapGrp1,
                                	t1.alder2
                                order by
                                	ar,
                                	regiondelNamn,
                                	sunRuapGrp,
                                	alder
                      ")

koefVidareutbildade <- dbGetQuery(con,"
                                        select
                                            t1.ar2 as ar,
                                            t3.regiondel_namn as regiondelNamn,
                                            t1.sunRuapGrp1 as sunRuapGrp,
                                        	  t1.alder2 as alder,
                                            count(*) as vidareutbildade
                                        from
                                            P0927.KP_IndataFlode t1,
                                            P0927.tmp_kommungrupper t2,
											                      P0927.tmp_kommungrupper t3
                                        where
                                            t1.alder2 between 21 and 68
                                            and t2.Regiondel_namn = t3.Regiondel_namn
                                            and t1.ExamAr2 = t1.ar2
                                            and t1.kommun1 = t2.Kommun
											                      and t1.kommun1 = t3.Kommun
                                        group by
                                            t1.ar2,
                                            t3.regiondel_namn,
                                            t1.sunRuapGrp1,
                                        	t1.alder2
                                        order by
                                        	ar,
                                        	regiondelNamn,
                                        	sunRuapGrp,
                                        	alder    
                          ")

koefUtflyttade <- dbGetQuery(con,"
                                  select
                                      t1.ar2 as ar,
                                      t2.regiondel_namn as regiondelNamn,
                                      t1.sunRuapGrp2 as sunRuapGrp,
                                  	  t1.alder2 as alder,
                                      count(*) as utflyttade
                                  from
                                      P0927.KP_IndataFlode t1,
                                      P0927.tmp_kommungrupper t2,
										            	    P0927.tmp_kommungrupper t3
                                  where
                                      t1.alder2 between 21 and 68
                                      and t1.kommun1 = t2.Kommun
									                    and t1.kommun2 = t3.Kommun
									                    and t2.regiondel_namn != t3.regiondel_namn
									                    and t1.ExamAr2!=ar2
                                  group by
                                      t1.ar2,
                                      t2.regiondel_namn,
                                      t1.sunRuapGrp2,
                                  	  t1.alder2
                                  order by
                                  	ar,
                                  	regiondelNamn,
                                  	sunRuapGrp,
                                  	alder
                                  ")

koefExaminerade <- dbGetQuery(con,"
                                  select
                                      t1.ar2 as ar,
                                      t3.regiondel_namn as regiondelNamn,
                                      t1.sunRuapGrp2 as sunRuapGrp,
                                  	  t1.alder2 as alder,
                                      count(*) as examinerade
                                  from
                                      P0927.KP_IndataFlode t1,
                                      P0927.tmp_kommungrupper t2,
										                	P0927.tmp_kommungrupper t3
                                  where
                                      t1.alder2 between 21 and 68
                                      and t1.kommun1 = t2.Kommun
									                    and t1.kommun2 = t3.Kommun
                                      and t2.Regiondel_namn = t3.Regiondel_namn
                                      and examAr2 = ar2
                                  group by
                                      t1.ar2,
                                      t3.Regiondel_namn,
                                      t1.sunRuapGrp2,	
                                  	  t1.alder2
                                  order by
                                  	ar,
                                  	regiondelNamn,
                                  	sunRuapGrp,
                                  	alder
                            ")

koefInflyttade <- dbGetQuery(con,"
                                select
                                    t1.ar2 as ar,
                                    t2.regiondel_namn as regiondelNamn,
                                    t1.sunRuapGrp1 as sunRuapGrp,
                                	t1.alder2 as alder,
                                    count(*) as inflyttade
                                from
                                    P0927.KP_IndataFlode t1,
                                    P0927.tmp_kommungrupper t2,
									                  P0927.tmp_kommungrupper t3
                                where
                                    t1.alder2 between 21 and 68
                                      and t1.kommun1 = t2.Kommun
									                    and t1.kommun2 = t3.Kommun
									                    and t2.Regiondel_namn != t3.Regiondel_namn
									                    
									                    and t1.ExamAr2!=ar2
                                group by
                                    t1.ar2,
                                    t2.regiondel_namn,
                                    t1.sunRuapGrp1,
                                	  t1.alder2
                                order by
                                  	ar,
                                  	regiondelNamn,
                                  	sunRuapGrp,
                                  	alder
                            ")

Koefficienter <- Koefficienter %>%
  filter(ar <= maxAr & ar >= minAr) %>%
  left_join(koefVidareutbildade, by=c("ar"="ar", "regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "alder"="alder")) %>%
  left_join(koefUtflyttade, by=c("ar"="ar", "regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "alder"="alder")) %>%
  left_join(koefExaminerade, by=c("ar"="ar", "regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "alder"="alder")) %>%
  left_join(koefInflyttade, by=c("ar"="ar", "regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "alder"="alder"))

aldrar <- seq(minAlder+1, maxAlder)
dfAldrar <- data.frame(aldrar)
dfAldrar <- sqldf("select t1.aldrar,
                    t2.aldersGrupp
                   from dfAldrar t1
                   left join aldersGrupp t2
                   on t1.aldrar >= t2.fran and t1.aldrar <=till")

dfExpanded <- Koefficienter %>%
  group_by(ar, regiondelNamn, sunRuapGrp) %>%
  expand(alder=dfAldrar$aldrar) %>%
  ungroup
Koefficienter <- dfExpanded  %>%
  left_join(Koefficienter, by=c("ar", "regiondelNamn", "sunRuapGrp", "alder"))
Koefficienter <- replace_na(Koefficienter, replace = list(inTotalt=0, vidareutbildade=0, utflyttade=0, examinerade=0, inflyttade=0))
Koefficienter <- Koefficienter %>%
  left_join(dfAldrar, by=c("alder"="aldrar"))

KoefficienterMedel <- Koefficienter %>%
  select(-"ar") %>%
  group_by(regiondelNamn, sunRuapGrp, aldersGrupp) %>%
  summarise(mInTotalt = mean(inTotalt, na.rm = TRUE),
            mUtflyttade = mean(utflyttade, na.rm = TRUE),
            mVidareutbildade = mean(vidareutbildade, na.rm = TRUE),
            mExaminerade = mean(examinerade, na.rm = TRUE),
            mInflyttade = mean(inflyttade, na.rm = TRUE)
  ) %>%
  ungroup()

Koefficienter <- Koefficienter %>%
  distinct(regiondelNamn, sunRuapGrp, alder, aldersGrupp) %>%
  left_join(KoefficienterMedel, by=c("regiondelNamn"="regiondelNamn", "sunRuapGrp"="sunRuapGrp", "aldersGrupp"="aldersGrupp"))

Koefficienter <- Koefficienter %>%
  mutate(kUtflyttade = mUtflyttade/mInTotalt,
         kVidareutbildade = mVidareutbildade/mInTotalt,
         kExaminerade = mExaminerade/mInTotalt,
         kInflyttade = mInflyttade/mInTotalt
  ) %>%
  replace_na(replace = list(kUtflyttade=0, kVidareutbildade=0, kExaminerade=0, kInflyttade=0))

#Beräknar utbildningsstrukturen för 20 åringar. Åldersinträde.
aAldersIntrade <- dbGetQuery(con,"
                                select
									                t1.ar2 as ar,
                                	t1.regiondelNamn,
                                	t1.sunRuapGrp,
                                	cast(t1.aldersIntradeUtb as float)/cast(t2.aldersIntrade as float) as aAldersintrade
                                FROM
                        					(
                        						SELECT
                        							t1.ar2,
                        							t2.regiondel_namn as regiondelNamn,
                											t1.sunRuapGrp2 as sunRuapGrp,
                											count(*) as aldersIntradeUtb
                        						FROM
                        							P0927.KP_IndataFlode t1,
        											        [P0927].[tmp_kommungrupper] t2
                        						where
                        							alder2=20
                        							and t1.kommun2=t2.kommun
                        						GROUP BY
        										        	t1.ar2,
                        							t2.regiondel_namn,
        											        t1.sunRuapGrp2											
                      				  	) t1,
                      					(
                      						select
                      							t1.ar2,
                      							t2.regiondel_namn as regiondelNamn,
                      							count(*) as aldersIntrade
                      						FROM
                      							P0927.KP_IndataFlode t1,
      											        [P0927].[tmp_kommungrupper] t2
                      						WHERE
                      							alder2 = 20
                      							and t1.kommun2=t2.kommun
                      						GROUP BY
      											        t1.ar2,
                      							t2.regiondel_namn
                      					) t2
                            where
                            	t1.regiondelNamn=t2.regiondelNamn
                            	and t1.ar2=t2.ar2
                    				order by
									            ar,
                    					regiondelNamn,
                    					sunRuapGrp
                            ")

aAldersIntrade <- aAldersIntrade %>%
  filter(ar <= maxAr & ar >= minAr) %>%
  select(-"ar") %>%
  group_by(regiondelNamn, sunRuapGrp) %>%
  summarise(mAldersIntrade = mean(aAldersintrade, na.rm = TRUE)) %>%
  ungroup

#Beräknar sysselsättningsgrad

dfSyssGrad <- dbGetQuery(con,"
                                select
                                	t1.ar,
                                	t2.Regiondel_namn as regiondelNamn,
                                	t1.sunRuapGrp,
                                	t1.alder,
                                	sum(t1.totalt) as totalt,
                                	sum(t1.syss) as syss
                                FROM
                                	[P0927].[syssPerUtbGrp] t1,
                                	[P0927].[tmp_kommungrupper] t2
                                WHERE
                                  t1.kommun=t2.Kommun
                                  and t1.alder between 20 and 68
                                GROUP BY
                                 	t1.ar,
                                	t2.Regiondel_namn,
                                	t1.sunRuapGrp,
                                	t1.alder                               
                                
                        ")

dfSyssGrad <- dfSyssGrad %>%
  filter(ar <= maxAr & ar >= minAr) %>%
  group_by(regiondelNamn, sunRuapGrp, alder) %>%
  summarise(totalt=sum(totalt),
            syss=sum(syss)) %>%
  ungroup()
dfSyssGrad <- dfSyssGrad %>%
  mutate(syssGrad=syss/totalt)


#Exporterar till Excel.
wb <- createWorkbook()
addWorksheet(wb, "Koefficienter")
writeData(wb, sheet="Koefficienter", x=Koefficienter)
addWorksheet(wb, "AldersIntrade")
writeData(wb, sheet="AldersIntrade", x=aAldersIntrade)
addWorksheet(wb, "syssGrad")
writeData(wb, sheet="syssGrad", x=dfSyssGrad)
saveWorkbook(wb, "./Konfiguration/koefficienter.xlsx", overwrite = TRUE)

#Rensar upp i tabeller och variabler
dbRemoveTable(con,"tmp_kommungrupper")
rm(Koefficienter)
rm(koefVidareutbildade)
rm(koefUtflyttade)
rm(koefExaminerade)
rm(koefInflyttade)
rm(KoefficienterMedel)
rm(aAldersIntrade)
rm(dfSyssGrad)
rm(aldersGrupp)
rm(kommunGrupper)
rm(styrVariabler)
rm(sunRuapGrpNamn)
rm(con)
rm(basArSkattning)
rm(maxAlder)
rm(maxAr)
rm(minAr)
rm(prognosperiod)
rm(sistObsAr)
rm(skattningsperiod)
rm(wb)
rm(dfAldrar, dfExpanded)
rm(PGMatchning, PGRelativlon)
rm(aldrar, minAlder)
rm(antalUtbGrp, minAntalIUtbGrp)
rm(dfUtbildningsgrupper, dfUtbildningsgrupperNyckel, PGUtbud)
