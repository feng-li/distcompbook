rm(list=ls(all=TRUE))

set.seed(1967)

options(digits = 4)

pdf.options(height=10/2.54, width=10/2.54, family="GB1") # 注意：此设置要放在最后

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  echo = TRUE,
  cache = TRUE,
  out.width = "90%",
  fig.align = 'center',
  # fig.width = 7,
  # fig.asp = 0.618,  # 1 / phi
  warning = FALSE,
  message = FALSE,
  tidy = TRUE
)


cggplot <- function(...){
  ggplot(...) + theme(text = element_text(family = "STSong"))
}

