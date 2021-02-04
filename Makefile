all: matches_1.csv matches_2.csv \
  tmhs_tmhmm_1.csv tmhs_tmhmm_2.csv \
  tmhs_pureseqtm_1.csv tmhs_pureseqtm_2.csv

not_now: results.csv

matches_1.csv:
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

clean:
	rm *.csv
