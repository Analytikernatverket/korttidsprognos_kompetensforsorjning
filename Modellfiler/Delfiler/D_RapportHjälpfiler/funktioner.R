formatCellXLSX <- function(workbook, flik, df) {
  rader <- nrow(df) + 1
  posStyle <- createStyle(bgFill = "#cefad0")
  negStyle <- createStyle(bgFill = '#ffc9d1')
  neutralStyle <- createStyle(bgFill = '#fff394')
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 19:22, rule = ">0", style=posStyle)
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 19:22, rule = "==0", style=neutralStyle)
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 19:22, rule = "<0", style=negStyle)
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 23, rule = ">1", style=posStyle)
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 23, type="between", rule = c(-1, 1), style=neutralStyle)
  conditionalFormatting(workbook, flik,
                        rows = 2:rader,
                        cols = 23, rule = "<-1", style=negStyle)
}
