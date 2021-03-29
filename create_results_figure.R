t <- readr::read_csv("results.csv")
t$mhc_class <- as.character(as.roman(t$mhc_class))
t$mhc_class <- as.factor(t$mhc_class)
t$tool <- as.factor(t$tool)
library(ggplot2)

ggplot2::ggplot(t, ggplot2::aes(x = tool, y = f_tmh)) +
  ggplot2::geom_col() +
  ggplot2::scale_y_continuous(
    "Percentage of epitopes that are predicted to be TMH",
    labels = scales::percent
  ) +
  ggplot2::scale_x_discrete(
    "TMH prediction tool"
  ) +
  ggplot2::facet_grid(
    . ~ mhc_class,
    labeller = ggplot2::as_labeller(c(I = "MHC-I", II = "MHC-II"))
  ) + ggplot2::theme_bw() +
  ggplot2::theme(axis.line = ggplot2::element_line(colour = "black"),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.background = ggplot2::element_blank(),
    legend.key = ggplot2::element_blank(),
    strip.background = element_rect(colour="white", fill="#FFFFFF")
  ) + ggplot2::ggsave("results.png", width = 7, height = 7)
