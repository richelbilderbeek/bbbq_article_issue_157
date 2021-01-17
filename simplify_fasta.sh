#!/bin/bash
egrep "LAPM5_HUMAN" UP000005640_9606.fasta -A 13 > tmp.fasta
mv tmp.fasta UP000005640_9606.fasta

