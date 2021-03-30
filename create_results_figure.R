t <- readr::read_csv("results.csv")
t$mhc_class <- as.character(as.roman(t$mhc_class))
t$mhc_class <- as.factor(t$mhc_class)
t$tool <- as.factor(t$tool)
library(ggplot2)

ggplot2::ggplot(t, ggplot2::aes(x = tool, y = f_tmh)) +
  ggplot2::geom_col(fill = "#BBBBBB") +
  ggplot2::scale_y_continuous(
    "Epitopes derived from TMH",
    labels = scales::percent
  ) +
  ggplot2::scale_x_discrete(
    "TMH prediction tool"
  ) +
  ggplot2::facet_grid(
    . ~ mhc_class,
    labeller = ggplot2::as_labeller(c(I = "MHC-I", II = "MHC-II"))
  ) + bbbq::get_bbbq_theme() +
  ggplot2::theme(text = ggplot2::element_text(size = 24)) +
  ggplot2::ggsave("results.png", width = 7, height = 7)

