all: results.csv results.tiff results.png

# Create the LaTeX table
tex: results.csv
	Rscript create_results_tex.R

matches_1.csv:
	Rscript -e 'remotes::install_github("richelbilderbeek/bianchi_et_al_2017")'
	Rscript create_matches_csv.R 1

matches_2.csv:
	Rscript create_matches_csv.R 2

tmhs_tmhmm_1.csv: matches_1.csv
	Rscript create_tmhs_tmhmm_csv.R 1

tmhs_tmhmm_2.csv: matches_2.csv
	Rscript create_tmhs_tmhmm_csv.R 2

tmhs_pureseqtm_1.csv: matches_1.csv
	Rscript create_tmhs_pureseqtm_csv.R 1

tmhs_pureseqtm_2.csv: matches_2.csv
	Rscript create_tmhs_pureseqtm_csv.R 2

results.csv: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_csv.R

results.png: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_figure.R

results.tiff: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_figure.R

results.csv: tmhs_tmhmm_1.csv tmhs_pureseqtm_1.csv tmhs_tmhmm_2.csv tmhs_pureseqtm_2.csv
	Rscript create_results_tex.R

clean:
	rm *.csv
