all: \
     results_per_allele.csv  \
     results_all_alleles.csv  \
     results.png \
     results.tex \
     figure_2d.png \
     results.tiff
     # results_all_alleles.csv  \

#
# IEDB
#

# General tables

iedb_b_cell_epitopes_and_mhc_alleles.csv: 
	Rscript create_iedb_b_cell_epitopes_and_mhc_alleles.R

iedb_mhc_ligand_epitopes_and_mhc_alleles.csv:
	Rscript create_iedb_mhc_ligand_epitopes_and_mhc_alleles.R

iedb_t_cell_epitopes_and_mhc_alleles.csv:
	Rscript create_iedb_t_cell_epitopes_and_mhc_alleles.R

# Specialized tables

# Per allele, MHC-I
iedb_b_cell_per_allele_1.csv: create_iedb_csv.R iedb_b_cell_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_b_cell per_allele 1

iedb_mhc_ligand_per_allele_1.csv: create_iedb_csv.R iedb_mhc_ligand_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_mhc_ligand per_allele 1

iedb_t_cell_per_allele_1.csv: create_iedb_csv.R iedb_t_cell_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_t_cell per_allele 1

# All alleles, MHC-I
#iedb_b_cell_all_alleles_1.csv: create_iedb_csv.R iedb_b_cell_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_b_cell all_alleles 1

#iedb_mhc_ligand_all_alleles_1.csv: create_iedb_csv.R iedb_mhc_ligand_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_mhc_ligand all_alleles 1

#iedb_t_cell_all_alleles_1.csv: create_iedb_csv.R iedb_t_cell_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_t_cell all_alleles 1

# Per allele, MHC-II
iedb_b_cell_per_allele_2.csv: create_iedb_csv.R iedb_b_cell_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_b_cell per_allele 2

iedb_mhc_ligand_per_allele_2.csv: create_iedb_csv.R iedb_mhc_ligand_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_mhc_ligand per_allele 2

iedb_t_cell_per_allele_2.csv: create_iedb_csv.R iedb_t_cell_epitopes_and_mhc_alleles.csv
	Rscript create_iedb_csv.R iedb_t_cell per_allele 2

# All alleles, MHC-II
#iedb_b_cell_all_alleles_2.csv: create_iedb_csv.R iedb_b_cell_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_b_cell all_alleles 2

#iedb_mhc_ligand_all_alleles_2.csv: create_iedb_csv.R iedb_mhc_ligand_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_mhc_ligand all_alleles 2

#iedb_t_cell_all_alleles_2.csv: create_iedb_csv.R iedb_t_cell_epitopes_and_mhc_alleles.csv
#	Rscript create_iedb_csv.R iedb_t_cell all_alleles 2

#
# matches
#
matches_schellens_all_alleles_1.csv: create_matches_csv.R
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
	Rscript -e 'remotes::install_github("richelbilderbeek/iedbr")'
	Rscript create_matches_csv.R 1 schellens all_alleles

matches_bergseng_all_alleles_2.csv: create_matches_csv.R
	Rscript create_matches_csv.R 2 bergseng all_alleles

# IEBD, all alleles

#matches_iedb_b_cell_all_alleles_1.csv: iedb_b_cell_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 1 iedb_b_cell all_alleles

#matches_iedb_mhc_ligand_all_alleles_1.csv: iedb_mhc_ligand_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 1 iedb_mhc_ligand all_alleles

#matches_iedb_t_cell_all_alleles_1.csv: iedb_t_cell_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 1 iedb_t_cell all_alleles

#matches_iedb_b_cell_all_alleles_2.csv: iedb_b_cell_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 2 iedb_b_cell all_alleles

#matches_iedb_mhc_ligand_all_alleles_2.csv: iedb_mhc_ligand_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 2 iedb_mhc_ligand all_alleles

#matches_iedb_t_cell_all_alleles_2.csv: iedb_t_cell_all_alleles.csv create_matches_csv.R
#	Rscript create_matches_csv.R 2 iedb_t_cell all_alleles

# IEBD, per allele
matches_iedb_b_cell_per_allele_1.csv: iedb_b_cell_per_allele_1.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_b_cell per_allele

matches_iedb_mhc_ligand_per_allele_1.csv: iedb_mhc_ligand_per_allele_1.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_mhc_ligand per_allele

matches_iedb_t_cell_per_allele_1.csv: iedb_t_cell_per_allele_1.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb_t_cell per_allele

matches_iedb_b_cell_per_allele_2.csv: iedb_b_cell_per_allele_2.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_b_cell per_allele

matches_iedb_mhc_ligand_per_allele_2.csv: iedb_mhc_ligand_per_allele_2.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_mhc_ligand per_allele

matches_iedb_t_cell_per_allele_2.csv: iedb_t_cell_per_allele_2.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb_t_cell per_allele

#
# TMHs TMHMM
#
# TMHs TMHMM all_alleles
tmhs_tmhmm_schellens_all_alleles_1.csv: matches_schellens_all_alleles_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 schellens all_alleles

#tmhs_tmhmm_iedb_b_cell_all_alleles_1.csv: matches_iedb_b_cell_all_alleles_1.csv
#	Rscript create_tmhs_tmhmm_csv.R 1 iedb_b_cell all_alleles

#tmhs_tmhmm_iedb_mhc_ligand_all_alleles_1.csv: matches_iedb_mhc_ligand_all_alleles_1.csv
#	Rscript create_tmhs_tmhmm_csv.R 1 iedb_mhc_ligand all_alleles

#tmhs_tmhmm_iedb_t_cell_all_alleles_1.csv: matches_iedb_t_cell_all_alleles_1.csv
#	Rscript create_tmhs_tmhmm_csv.R 1 iedb_t_cell all_alleles

tmhs_tmhmm_bergseng_all_alleles_2.csv: matches_bergseng_all_alleles_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 bergseng all_alleles

#tmhs_tmhmm_iedb_b_cell_all_alleles_2.csv: matches_iedb_b_cell_all_alleles_2.csv
#	Rscript create_tmhs_tmhmm_csv.R 2 iedb_b_cell all_alleles

#tmhs_tmhmm_iedb_mhc_ligand_all_alleles_2.csv: matches_iedb_mhc_ligand_all_alleles_2.csv
#	Rscript create_tmhs_tmhmm_csv.R 2 iedb_mhc_ligand all_alleles

#tmhs_tmhmm_iedb_t_cell_all_alleles_2.csv: matches_iedb_t_cell_all_alleles_2.csv
#	Rscript create_tmhs_tmhmm_csv.R 2 iedb_t_cell all_alleles

# TMHs TMHMM per_allele

# Schellens and Bergseng are all-_alleles-only
 tmhs_tmhmm_schellens_per_allele_1.csv: matches_schellens_per_allele_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 schellens per_allele

tmhs_tmhmm_iedb_b_cell_per_allele_1.csv: matches_iedb_b_cell_per_allele_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_b_cell per_allele

tmhs_tmhmm_iedb_mhc_ligand_per_allele_1.csv: matches_iedb_mhc_ligand_per_allele_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_mhc_ligand per_allele

tmhs_tmhmm_iedb_t_cell_per_allele_1.csv: matches_iedb_t_cell_per_allele_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1 iedb_t_cell per_allele

# Schellens and Bergseng are all-_alleles-only
tmhs_tmhmm_bergseng_per_allele_2.csv: matches_bergseng_per_allele_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 bergseng per_allele

tmhs_tmhmm_iedb_b_cell_per_allele_2.csv: matches_iedb_b_cell_per_allele_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_b_cell per_allele

tmhs_tmhmm_iedb_mhc_ligand_per_allele_2.csv: matches_iedb_mhc_ligand_per_allele_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_mhc_ligand per_allele

tmhs_tmhmm_iedb_t_cell_per_allele_2.csv: matches_iedb_t_cell_per_allele_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2 iedb_t_cell per_allele

#
# TMHs PureseqTM
#
# TMHs PureseqTM all_alleles
tmhs_pureseqtm_schellens_all_alleles_1.csv: matches_schellens_all_alleles_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 schellens all_alleles

#tmhs_pureseqtm_iedb_b_cell_all_alleles_1.csv: matches_iedb_b_cell_all_alleles_1.csv
#	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_b_cell all_alleles

#tmhs_pureseqtm_iedb_mhc_ligand_all_alleles_1.csv: matches_iedb_mhc_ligand_all_alleles_1.csv
#	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_mhc_ligand all_alleles

#tmhs_pureseqtm_iedb_t_cell_all_alleles_1.csv: matches_iedb_t_cell_all_alleles_1.csv
#	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_t_cell all_alleles

tmhs_pureseqtm_bergseng_all_alleles_2.csv: matches_bergseng_all_alleles_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 bergseng all_alleles

#tmhs_pureseqtm_iedb_b_cell_all_alleles_2.csv: matches_iedb_b_cell_all_alleles_2.csv
#	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_b_cell all_alleles

#tmhs_pureseqtm_iedb_mhc_ligand_all_alleles_2.csv: matches_iedb_mhc_ligand_all_alleles_2.csv
#	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_mhc_ligand all_alleles

#tmhs_pureseqtm_iedb_t_cell_all_alleles_2.csv: matches_iedb_t_cell_all_alleles_2.csv
#	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_t_cell all_alleles

# TMHs PureseqTM per_allele
# Schellens and Bergseng are all-_alleles-only
 tmhs_pureseqtm_schellens_per_allele_1.csv: matches_schellens_per_allele_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 schellens per_allele

tmhs_pureseqtm_iedb_b_cell_per_allele_1.csv: matches_iedb_b_cell_per_allele_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_b_cell per_allele

tmhs_pureseqtm_iedb_mhc_ligand_per_allele_1.csv: matches_iedb_mhc_ligand_per_allele_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_mhc_ligand per_allele

tmhs_pureseqtm_iedb_t_cell_per_allele_1.csv: matches_iedb_t_cell_per_allele_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1 iedb_t_cell per_allele

# Schellens and Bergseng are all-_alleles-only
tmhs_pureseqtm_bergseng_per_allele_2.csv: matches_bergseng_per_allele_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 bergseng per_allele

tmhs_pureseqtm_iedb_b_cell_per_allele_2.csv: matches_iedb_b_cell_per_allele_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_b_cell per_allele

tmhs_pureseqtm_iedb_mhc_ligand_per_allele_2.csv: matches_iedb_mhc_ligand_per_allele_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_mhc_ligand per_allele

tmhs_pureseqtm_iedb_t_cell_per_allele_2.csv: matches_iedb_t_cell_per_allele_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2 iedb_t_cell per_allele

#
# Results
#
results_all_alleles.csv: create_results_csv.R \
             tmhs_pureseqtm_bergseng_all_alleles_2.csv \
             tmhs_pureseqtm_schellens_all_alleles_1.csv \
             tmhs_tmhmm_bergseng_all_alleles_2.csv \
             tmhs_tmhmm_schellens_all_alleles_1.csv
	Rscript create_results_csv.R all_alleles

results_per_allele.csv: create_results_csv.R \
             tmhs_tmhmm_iedb_b_cell_per_allele_1.csv \
             tmhs_tmhmm_iedb_t_cell_per_allele_1.csv \
             tmhs_tmhmm_iedb_b_cell_per_allele_2.csv \
             tmhs_tmhmm_iedb_t_cell_per_allele_2.csv \
             tmhs_tmhmm_iedb_mhc_ligand_per_allele_1.csv \
             tmhs_tmhmm_iedb_mhc_ligand_per_allele_2.csv \
             tmhs_pureseqtm_iedb_mhc_ligand_per_allele_1.csv \
             tmhs_pureseqtm_iedb_mhc_ligand_per_allele_2.csv \
             tmhs_pureseqtm_iedb_b_cell_per_allele_1.csv \
             tmhs_pureseqtm_iedb_t_cell_per_allele_1.csv \
             tmhs_pureseqtm_iedb_b_cell_per_allele_2.csv \
             tmhs_pureseqtm_iedb_t_cell_per_allele_2.csv
	Rscript create_results_csv.R per_allele


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
