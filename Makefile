all: results.csv

matches.csv:
	Rscript create_matches_csv.R

tmhs_tmhmm.csv: matches.csv
	Rscript create_tmhs_tmhmm_csv.R

tmhs_pureseqtm.csv: matches.csv
	Rscript create_tmhs_pureseqtm_csv.R

results.csv: tmhs_tmhmm.csv tmhs_pureseqtm.csv
	Rscript create_results_csv.R
