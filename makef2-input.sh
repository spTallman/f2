vcf=$1
chromRow=$(grep -P -n "#CHROM" $vcf | awk -F":" '{print $1}')
tail -n+$chromRow $vcf | cut -f 10- - > $2

