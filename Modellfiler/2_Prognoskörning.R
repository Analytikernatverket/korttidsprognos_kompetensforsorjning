starttid_prognos <- Sys.time()
source("./Modellfiler/Delfiler/A_utbudsprognos.R", encoding = 'UTF-8')
source("./Modellfiler/Delfiler/B_efterfrågeanalys.R", encoding = 'UTF-8')
source("./Modellfiler/Delfiler/C_poangbedömning.R", encoding = 'UTF-8')
source("./Modellfiler/Delfiler/D_Rapporttabell.R", encoding = 'UTF-8')
source("./Modellfiler/Delfiler/E_skapa_powerPoint.R", encoding = 'UTF-8')

file.remove("./tmpFiler/poang.xlsx")
file.remove("./tmpFiler/ResultatEfterfrågeprognos.xlsx")
file.remove("./tmpFiler/ResultatUtbudsprognos.xlsx")

sluttid_prognos <- Sys.time()
kortid <- difftime(sluttid_prognos, starttid_prognos, units = "secs")
kortid_prognos <- sprintf("%02d:%02d:%02d",
                         as.integer(kortid) %/% 3600,
                         (as.integer(kortid) %% 3600) %/% 60,
                         as.integer(kortid) %% 60
)


print(cat("Körtiden för utbudsprognosen: ", kortid_utbud))
print(cat("Körtiden för efterfrågeprognosen: ", kortid_efterfragan))
print(cat("Körtiden för sammanvägning med poäng: ", kortid_poang))
print(cat("Körtiden för skrivandet av rapporttabell: ",kortid_rapport))
print(cat("Körtiden för PowerPoint skrivandet: ", kortid_pptx))
print(cat("Körtiden för hela prognosen är: ", kortid_prognos))
rm(kortid, kortid_prognos, sluttid_prognos, starttid_prognos)
rm(kortid_efterfragan, kortid_poang, kortid_rapport, kortid_utbud, kortid_pptx)

