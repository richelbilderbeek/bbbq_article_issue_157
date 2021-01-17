all: UP000005640_9606.fasta

UP000005640_9606.fasta.gz: 
	Rscript -e 'bianchietal2017::download_proteome(fasta_gz_filename = "UP000005640_9606.fasta.gz")'

UP000005640_9606.fasta: 
	Rscript -e 'bianchietal2017::get_proteome(fasta_gz_filename = "UP000005640_9606.fasta.gz", fasta_filename = "UP000005640_9606.fasta")'


