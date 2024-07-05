fskapa_flodesdiagram <- function(dflode_urval, title_txt = "Utbudsflöde") {
  library(tidyverse)
  source("./Modellfiler/Delfiler/E_PowerpointHjälpfiler/theme_skane_mod.R", encoding = "utf-8")
  
  dia_flode <- dflode_urval %>%
    ggplot(aes(antal, kategori, fill = pos_neg)) +
    theme_skane() +
    scale_fill_manual(values = skala_stapel_farg) +
    geom_col(linewidth = 1, colour = "black") +
    labs(title = title_txt) +
    guides(fill = "none") +
    labs(x = NULL,
         y = NULL) +
    theme(plot.title = element_text(hjust=0.5))
  
  return(dia_flode)
  
}

