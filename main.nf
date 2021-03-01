
/*
input params
*/
params.bam='*.bam'






log.info """\
         R N A S E Q - N F   P I P E L I N E
         ===================================
         bamPattern:         : ${params.bam}
         """
         .stripIndent()


bam_ch = Channel.fromPath(params.bam)


process combine_ids {

 input:
 path(bam) from bam_ch;

 output:
 path("${sampleID}_header.txt")into header_ch


 script:
 sampleID = bam.baseName
 """
 samtools index ${bam}
 printf "${sampleID}\t" > ${sampleID}_header.txt
 samtools view ${bam} |head -n1|cut -f1 |tr ":" "\t" >> ${sampleID}_header.txt
 """
}


process combine_heads {
  publishDir "results"

  input:
  path(header) from header_ch.collect()

  output:
  path("results.txt")

  script:
  """
  cat ${header} > results.txt
  """
}
