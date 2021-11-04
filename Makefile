all: iedb_b_cell_per_allele.csv \
     iedb_mhc_ligand_per_allele.csv \
     iedb_t_cell_per_allele.csv \
     iedb_b_cell_all_alleles.csv \
     iedb_mhc_ligand_all_alleles.csv \
     iedb_t_cell_all_alleles.csv \
     results.csv \
     results.png \
     results.tex \
     figure_2d.png
     # results.tiff \

#
# IEDB
#
iedb_b_cell_per_allele.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_b_cell per_allele

iedb_t_cell_per_allele.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_t_cell per_allele

iedb_mhc_ligand_per_allele.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_mhc_ligand per_allele

iedb_b_cell_all_alleles.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_b_cell all_alleles

iedb_t_cell_all_alleles.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_t_cell all_alleles

iedb_mhc_ligand_all_alleles.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R iedb_mhc_ligand all_alleles

#
# matches
#
matches_schellens_1.csv: create_matches_csv.R
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsr")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsrinstall")'
	Rscript -e 'if (!mhcnuggetsr::is_mhcnuggets_installed()) mhcnuggetsrinstall::install_mhcnuggets()'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnpreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/nmhc2ppreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/tmhmm")'
	Rscript -e 'remotes::install_github("richelbilderbeek/epiprepreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/pureseqtmr")'
	Rscript -e 'remotes::install_bioc("Biostrings")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bbbq")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bianchi_et_al_2017")'
	Rscript create_matches_csv.R 1 schellens

matches_bergseng_2.csv: create_matches_csv.R
	Rscript create_matches_csv.R 2 bergseng

matches_iedb_b_cell_1.csv: iedb_b_cell.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_b_cell

matches_iedb_mhc_ligand_1.csv: iedb_mhc_ligand.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_mhc_ligand

matches_iedb_t_cell_1.csv: iedb_t_cell.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_t_cell

matches_iedb_b_cell_2.csv: iedb_b_cell.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_b_cell

matches_iedb_mhc_ligand_2.csv: iedb_mhc_ligand.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_mhc_ligand

matches_iedb_t_cell_2.csv: iedb_t_cell.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_t_cell

#
# TMHs TMHMM
#
tmhs_tmhmm_schellens_1.csv: matches_schellens_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 schellens

tmhs_tmhmm_iedb_b_cell_1.csv: matches_iedb_b_cell_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_b_cell

tmhs_tmhmm_iedb_mhc_ligand_1.csv: matches_iedb_mhc_ligand_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_mhc_ligand

tmhs_tmhmm_iedb_t_cell_1.csv: matches_iedb_t_cell_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_t_cell

tmhs_tmhmm_bergseng_2.csv: matches_bergseng_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 bergseng

tmhs_tmhmm_iedb_b_cell_2.csv: matches_iedb_b_cell_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_b_cell

tmhs_tmhmm_iedb_mhc_ligand_2.csv: matches_iedb_mhc_ligand_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_mhc_ligand

tmhs_tmhmm_iedb_t_cell_2.csv: matches_iedb_t_cell_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_t_cell

#
# TMHs PureseqTM
#

tmhs_pureseqtm_schellens_1.csv: matches_schellens_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 schellens

tmhs_pureseqtm_iedb_b_cell_1.csv: matches_iedb_b_cell_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_b_cell

tmhs_pureseqtm_iedb_mhc_ligand_1.csv: matches_iedb_mhc_ligand_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_mhc_ligand

tmhs_pureseqtm_iedb_t_cell_1.csv: matches_iedb_t_cell_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_t_cell

tmhs_pureseqtm_bergseng_2.csv: matches_bergseng_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 bergseng

tmhs_pureseqtm_iedb_b_cell_2.csv: matches_iedb_b_cell_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_b_cell

tmhs_pureseqtm_iedb_mhc_ligand_2.csv: matches_iedb_mhc_ligand_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_mhc_ligand

tmhs_pureseqtm_iedb_t_cell_2.csv: matches_iedb_t_cell_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_t_cell

#
# Results
#
results.csv: tmhs_tmhmm_schellens_1.csv \
             tmhs_tmhmm_iedb_b_cell_1.csv \
             tmhs_tmhmm_iedb_t_cell_1.csv \
             tmhs_tmhmm_bergseng_2.csv \
             tmhs_tmhmm_iedb_b_cell_2.csv \
             tmhs_tmhmm_iedb_t_cell_2.csv \
             tmhs_tmhmm_iedb_mhc_ligand_1.csv \
             tmhs_tmhmm_iedb_mhc_ligand_2.csv \
             tmhs_pureseqtm_iedb_mhc_ligand_1.csv \
             tmhs_pureseqtm_iedb_mhc_ligand_2.csv \
             tmhs_pureseqtm_schellens_1.csv \
             tmhs_pureseqtm_iedb_b_cell_1.csv \
             tmhs_pureseqtm_iedb_t_cell_1.csv \
             tmhs_pureseqtm_bergseng_2.csv \
             tmhs_pureseqtm_iedb_b_cell_2.csv \
             tmhs_pureseqtm_iedb_t_cell_2.csv
	Rscript create_results_csv.R


results.png: results.csv create_results_figure.R
	Rscript create_results_figure.R

results.tiff: results.csv create_results_figure.R
	Rscript create_results_figure.R

results.tex: results.csv create_results_tex.R
	Rscript create_results_tex.R

# https://github.com/richelbilderbeek/bbbq_article/issues/245
figure_2d.png: results.csv create_figure_2d.R
	Rscript create_figure_2d.R

clean:
	rm *.csv
