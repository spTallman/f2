# f2
Script to calculate f2 alleles within and across populations from a VCF containing only doubletons
TESTED ON R VERSION 3.5.1

test.vcf is a VCF with 994 genotypes and 80 samples (MUST BE UNPHASED) from two populations POP1 and POP2
test.ids shows which samples are in POP1 and which are in POP2. It is a simple two column file with individual id in the first column and population id in the second column.
individual ids must match those in the VCF file.

First we need to extract only doubletons sites (Max allele count = 2, Min allele count = 2).
For example, we can use:

bcftools view test.vcf -C 2 -c 2 -o test.doubletons.vcf

Second we need to transform this vcf into a genotype matrix to input into the main script.
Added a simple companion script to do that:

bash makef2-input.sh test.doubletons.vcf test.doubletons.matrix
There should be a total of 208 loci where AC=2

Now we can estimate the number of f2 doubletons within+across populations:

Requires packages:
data.table, reshape2

Rscript f2_alleles.R test.doubletons.matrix test.ids test.f2

The resulting output should be:

POP1	POP1	63
POP2	POP1	69
POP2	POP2	76

This shows there are 63 doubletons shared within POP1, 76 within POP2 and 69 between POP1 and POP2.
