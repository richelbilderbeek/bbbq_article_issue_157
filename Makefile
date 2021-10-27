all: results.csv results.tiff results.png results.tex iedb.csv

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

iedb.csv: create_iedb_csv.R
	Rscript create_iedb_csv.R

matches_iedb_1.csv: iedb.csv create_matches_csv.R
	Rscript create_matches_csv.R 1 iedb

matches_iedb_2.csv: iedb.csv create_matches_csv.R
	Rscript create_matches_csv.R 2 iedb

tmhs_tmhmm_1.csv: matches_schellens_1.csv matches_iedb_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1

tmhs_tmhmm_2.csv: matches_bergseng_2.csv matches_iedb_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2

tmhs_pureseqtm_1.csv: matches_schellens_1.csv matches_iedb_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1

tmhs_pureseqtm_2.csv: matches_bergseng_2.csv matches_iedb_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2

results.csv: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_csv.R

results.png: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_figure.R

results.tiff: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_figure.R

results.tex: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_tex.R

clean:
	rm *.csv
