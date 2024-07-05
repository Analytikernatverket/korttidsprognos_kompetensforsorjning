library(ggplot2)
library(purrr)

# loadfonts("win")

fcolour_ramp <- function(col_from = "#E8FAFA", col_to = "#27697A", ant_col = 8) {
  colorRampPalette(c(col_from, col_to))( ant_col ) ## (n)
}

skala_stapel_farg <- c(
  "#307C8E",
  "#FDF9E4",
  "#5F5236",
  "#FDD32F",
  "#E40135",
  "#FFE8DB",
  "#1C8775",
  "#B5DEE0",
  "#80216E",
  "#E8E3F2",
  "#3B4AA6",
  "#B2C9F2",
  "#632424",
  "#E3F5EB",
  "#084775",
  "#8CDBC7",
  "#87549E",
  "#A3D48C",
  "#216648",
  "#E5BBD1",
  "#91786B",
  "#E3D1DE",
  "#964A24",
  "#EBB296",
  "#807380",
  "#C2BDDB",
  "#B22424",
  "#D9BDBD",
  "#8F7800",
  "#F2E08C",
  "black"
)

skala_linje_farg <- skala_stapel_farg[c(1, 3, 5, 7, 9, 11, 4, 19, 31, 20)]

skala_karta_enkel <- c(minsta = "#E8FAFA", max = "#27697A")
skala_karta_dubbel <- c(hogsta_neg = "#940622", mitt = "white", hogsta_pos = "#27697A")



theme_skane <- function(){
  new_theme <- theme_bw() +
    theme(legend.position = "bottom", 
          # legend.key = element_blank(),
          legend.text = element_text(size = rel(0.8)),
          legend.title = element_text(size = rel(0.8)),
          legend.margin=margin(c(1,0,1,0)),
          legend.box.spacing=unit(2, "pt"),
          axis.line.x.bottom=element_line(color="black", linewidth = 0.5),
          axis.text.y = element_text(color="black", size=rel(1)),
          axis.text.x = element_text(color="black", size=rel(1)),
          axis.title.y = element_text(size = rel(0.8), face = "bold", margin = margin(r = 5)), 
          axis.title.x = element_text(size = rel(0.8), face = "bold", margin = margin(t = 5)))

  
  return(new_theme)
}

theme_Skane_karta <- function(base_size = 12, border_size = 0.1) {

  getOutputFormat <- function() {

    output <-
      try(rmarkdown:::parse_yaml_front_matter(readLines(knitr::current_input()))$output,
          silent = TRUE)
    if (inherits(output, "try-error")) {
      return("not_markdown")
    }
    if (is.list(output)) {
      return(names(output)[1])
    } else {
      return(output[1])
    }
  }


  if (possibly(getOutputFormat, "rmarkdown", quiet = TRUE)() == "word_document") {
    base_size <- base_size * 0.9
  }

  new_theme <-
    theme_void(base_size = base_size) +
    theme(
      plot.title = element_text(size = rel(1), lineheight = 1.2),
      plot.subtitle = element_text(size = rel(0.8), lineheight = 1.2),
      legend.title = element_text(size = rel(0.8)),
      legend.text = element_text(size = rel(0.75)),
      legend.key.size = unit(0.5, "cm"),
      legend.position = "bottom",
      legend.background = element_blank(), # Remove overall border
      legend.key = element_blank(),  # Remove border around each item
      strip.text = element_text(face = "bold", size = rel(0.75)),
      plot.margin     =   unit(c(0,0,0,0),"lines"),
      panel.grid.major = element_line(colour = 'transparent'),
      panel.border = element_blank()
    )
  return(new_theme)
}
