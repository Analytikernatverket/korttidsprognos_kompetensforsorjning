ftrafikljusdia2 <- function(match_txt) {
  
  # Skapar ett trafikljusdiagram för den diagramtyp som anges parametern match_txt
  
  scale_fill_dia_match <- c("red", "yellow", "blue")
  
  

  if (match_txt$diagram == "Matchningseffekt") {
    dfdia = tibble( kat = c("Minskad efterfrågan", "Oförändrad efterfrågan", "Ökad efterfrågan"),
                    varde = 1L,
                    scale_alpha_dia = c(1/30, 1/30, 1/30),
                    scale_linewidth_dia =c(0.5, 0.5, 0.5))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = if_else(kat == match_txt$matartext,
                                  paste0("**", kat, "**"),
                                  paste0("*", kat, "*")),
             scale_linewidth_dia = if_else(kat == match_txt$matartext,
                                           1.5,
                                           scale_linewidth_dia),
             scale_alpha_dia = if_else(kat == match_txt$matartext,
                                       1,
                                       scale_alpha_dia)) %>% 
      mutate(labels_txt = str_replace_all(labels_txt, " ", "<br>"))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = factor(labels_txt, levels = pull(dfdia, labels_txt)))
    
    
    titel_txt = "Matchningseffekt"
    
  } else if (match_txt$diagram == "Reallöneutveckling") {
    dfdia = tibble( kat = c("Minskad efterfrågan", "Oförändrad efterfrågan", "Ökad efterfrågan"),
                    varde = 1L,
                    scale_alpha_dia = c(1/30, 1/30, 1/30),
                    scale_linewidth_dia =c(0.5, 0.5, 0.5))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = if_else(kat == match_txt$matartext,
                                  paste0("**", kat, "**"),
                                  paste0("*", kat, "*")),
             scale_linewidth_dia = if_else(kat == match_txt$matartext,
                                           1.5,
                                           scale_linewidth_dia),
             scale_alpha_dia = if_else(kat == match_txt$matartext,
                                       1,
                                       scale_alpha_dia)) %>% 
      mutate(labels_txt = str_replace_all(labels_txt, " ", "<br>"))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = factor(labels_txt, levels = pull(dfdia, labels_txt)))
    
    
    titel_txt = "Reallöneutveckling" 
  } else if (match_txt$diagram == "Sammanlagd efterfrågeeffekt") {
    dfdia = tibble( kat = c("Minskad efterfrågan", "Oförändrad efterfrågan", "Ökad efterfrågan"),
                    varde = 1L,
                    scale_alpha_dia = c(1/30, 1/30, 1/30),
                    scale_linewidth_dia =c(0.5, 0.5, 0.5))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = if_else(kat == match_txt$matartext,
                                  paste0("**", kat, "**"),
                                  paste0("*", kat, "*")),
             scale_linewidth_dia = if_else(kat == match_txt$matartext,
                                           1.5,
                                           scale_linewidth_dia),
             scale_alpha_dia = if_else(kat == match_txt$matartext,
                                       1,
                                       scale_alpha_dia)) %>% 
      mutate(labels_txt = str_replace_all(labels_txt, " ", "<br>"))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = factor(labels_txt, levels = pull(dfdia, labels_txt)))
    
    
    titel_txt = "Sammanlagd efterfrågeeffekt" 
  } else if (match_txt$diagram == "Utbudseffekt") {
    dfdia = tibble( kat = c("Minskat utbud", "Oförändrat utbud", "Ökat utbud"),
                    varde = 1L,
                    scale_alpha_dia = c(1/30, 1/30, 1/30),
                    scale_linewidth_dia =c(0.5, 0.5, 0.5))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = if_else(kat == match_txt$matartext,
                                  paste0("**", kat, "**"),
                                  paste0("*", kat, "*")),
             scale_linewidth_dia = if_else(kat == match_txt$matartext,
                                           1.5,
                                           scale_linewidth_dia),
             scale_alpha_dia = if_else(kat == match_txt$matartext,
                                       1,
                                       scale_alpha_dia)) %>% 
      mutate(labels_txt = str_replace_all(labels_txt, " ", "<br>"))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = factor(labels_txt, levels = pull(dfdia, labels_txt)))
    
    
    titel_txt = "Utbudseffekt" 
    
  } else if  (match_txt$diagram == "Arbetsmarknadens utveckling") {
    dfdia = tibble( kat = c("Svårate att få jobb", "Oförändrat", "Lättare att få jobb"),
                    varde = 1L,
                    scale_alpha_dia = c(1/30, 1/30, 1/30),
                    scale_linewidth_dia =c(0.5, 0.5, 0.5))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = if_else(kat == match_txt$matartext,
                                  paste0("**", kat, "**"),
                                  paste0("*", kat, "*")),
             scale_linewidth_dia = if_else(kat == match_txt$matartext,
                                           1.5,
                                           scale_linewidth_dia),
             scale_alpha_dia = if_else(kat == match_txt$matartext,
                                       1,
                                       scale_alpha_dia)) %>% 
      mutate(labels_txt = str_replace_all(labels_txt, "att ", "att<br>"))
    
    dfdia <- dfdia %>% 
      mutate(labels_txt = factor(labels_txt, levels = pull(dfdia, labels_txt)))
    
    
    titel_txt = "Arbetsmarknadens utveckling" 
  }
  
  dia_trafikljus <- ggplot(dfdia, aes(labels_txt, varde ,  fill = labels_txt, alpha = labels_txt, linewidth = labels_txt)) +
    theme_void() +
    geom_col(colour = "black", width = 1) +
    scale_x_discrete() +
    scale_fill_manual(values = scale_fill_dia_match) +
    scale_alpha_manual(values = pull(dfdia, scale_alpha_dia)) +
    scale_linewidth_manual(values = pull(dfdia, scale_linewidth_dia)) +
    guides(fill = "none") +
    guides(alpha = "none") +
    guides(linewidth = "none") +
    theme(
      axis.text.x = element_markdown(),
      plot.title = element_text(hjust=0.5)
    ) +
    labs(
      title = titel_txt
    )
  
  return(dia_trafikljus = dia_trafikljus)
  
}