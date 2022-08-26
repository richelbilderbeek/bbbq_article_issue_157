# bbbq_article_issue_157

Branch   |[![GitHub Actions logo](pics/GitHubActions.png)](https://github.com/richelbilderbeek/bbbq_article_issue_157/actions)
---------|---------------------------------------------------------------------------------------------------------------------------
`master` |![R-CMD-check](https://github.com/richelbilderbeek/bbbq_article_issue_157/workflows/R-CMD-check/badge.svg?branch=master)   
`develop`|![R-CMD-check](https://github.com/richelbilderbeek/bbbq_article_issue_157/workflows/R-CMD-check/badge.svg?branch=develop)  

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5809109.svg)](https://doi.org/10.5281/zenodo.5809109)

BBBQ article Issue 157.

![Result of BBBQ article Issue 157](results.png)

## Installation

From R, run:

```
remotes::install_github("richelbilderbeek/bianchi_et_al_2017")
remotes::install_github("richelbilderbeek/bbbq")
remotes::install_github("richelbilderbeek/pureseqtmr")
remotes::install_github("richelbilderbeek/tmhmm")
```

See [the tested GitHub Actions scripts](https://github.com/richelbilderbeek/bbbq_article_issue_157/blob/master/.github/workflows/R-CMD-check.yaml)
for more inspiration.

## Reproduce the results

From a terminal, do:

```
make
```

##

File                                   |Description
---------------------------------------|--------------------------------------------------------------------------------
iedb_b_cell_epitopes_and_allele.csv    |table with `linear_sequence` and `mhc_allele_name`, as presented by B cells
iedb_mhc_ligand_epitopes_and_allele.csv|table with `linear_sequence` and `mhc_allele_name` as detected using MHC ligands
iedb_t_cell_epitopes_and_allele.csv    |table with `linear_sequence` and `mhc_allele_name`, as presented by T cells


## Results

 * [results/results.csv](results/results.csv)
 * [results/tmhs_pureseqtm.csv](results/tmhs_pureseqtm_1.csv)
 * [results/tmhs_tmhmm.csv](results/tmhs_tmhmm_1.csv)
 * [results/tmhs_pureseqtm.csv](results/tmhs_pureseqtm_2.csv)
 * [results/tmhs_tmhmm.csv](results/tmhs_tmhmm_2.csv)
