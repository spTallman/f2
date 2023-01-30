#!/usr/bin/env Rscript


#### Script for finding f2 alleles shared within/between populations

args = commandArgs(trailingOnly=TRUE)
suppressPackageStartupMessages(library("data.table"))
suppressPackageStartupMessages(library("reshape2"))

idFile <- fread(args[2], header=F, select=c(1,2), col.names=c("pop", "iid"))

ids <- idFile$iid
pops <- idFile$pop
f2_summary <- matrix(nrow = length(unique(pops)), ncol = length(unique(pops)), 0)
colnames(f2_summary) <- unique(pops)
rownames(f2_summary) <- unique(pops)


con = file(args[1], open = "r")
# con = file("test.doubletons_matrix", open = "r")
vcfHeader <- strsplit(readLines(con, n=1), "\t")[[1]]
close(con)

#con = file("test.doubletons_matrix", open = "r")
con = file(args[1], open = "r")
while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
    myVector <- strsplit(oneLine, "\t")
    vector = myVector[[1]]
    f2index = grep("1/0|0/1", vector)
    if (length(f2index) == 2) {
        f2samples = vcfHeader[c(f2index[1], f2index[2])]
        id1 = f2samples[1]
        index1 <- which(ids %in% id1)
        pop1 = pops[index1]
        id2 = f2samples[2]
        index2 <- which(ids %in% id2)
        pop2 = pops[index2]
        if (id1 %in% ids & id2 %in% ids) {
            f2_summary[pop1, pop2] = f2_summary[pop1, pop2] + 1
            f2_summary[pop2, pop1] = f2_summary[pop1, pop2]
        } 
        next
    } 
    f2index <- grep("1/1", vector)
    if (length(f2index) == 1) {
        f2sample = vcfHeader[f2index[1]]
        index = which(ids %in% f2sample)
        pop = pops[index]
        if (f2sample %in% ids) {
            f2_summary[pop, pop] = f2_summary[pop, pop] + 1
        }
        next
    }
    f2index <- grep("0/0", vector)
    if (length(f2index) == 1) {
        f2sample = vcfHeader[f2index[1]]
        index = which(ids %in% f2sample)
        pop = pops[index]
        if (f2sample %in% ids) {
            f2_summary[pop, pop] = f2_summary[pop, pop] + 1
        }
    }
}
close(con)

f2_longData <- melt(f2_summary) 
f2_longData_unique <- f2_longData[!duplicated(apply(f2_longData,1,function(x) paste(sort(x),collapse='_'))),]

write.table(f2_longData_unique, args[3], sep="\t", col.names=F, row.names=F, quote=F)
