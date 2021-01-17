all: UP000005640_9606.fasta schellens_et_al_2015_sup_1.xlsx matches.csv

UP000005640_9606.fasta.gz: 
	Rscript -e 'bianchietal2017::download_proteome(fasta_gz_filename = "UP000005640_9606.fasta.gz")'

UP000005640_9606.fasta: 
	Rscript -e 'bianchietal2017::get_proteome(fasta_gz_filename = "UP000005640_9606.fasta.gz", fasta_filename = "UP000005640_9606.fasta")'

schellens_et_al_2015_sup_1.xlsx:
	Rscript -e 'bianchietal2017::download_schellens_et_al_2015_sup_1(xlsx_filename = "schellens_et_al_2015_sup_1.xlsx")'

matches.csv: UP000005640_9606.fasta schellens_et_al_2015_sup_1.xlsx
	Rscript create_matches_csv.R
