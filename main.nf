
/*
input params
*/
params.bam='alignment/*.{bam,bai}'
params.replace=''






log.info """\
         R N A S E Q - N F   P I P E L I N E
         ===================================
         bamPattern:         : ${params.bam}
         replacePattern:     : ${params.replace}
         """
         .stripIndent()


         Channel
             .fromFilePairs(params.bam) { file -> file.name.replaceAll(/.bam|.bai$/,'') }
             .set { bam_ch }


process combine_ids {

 input:
 tuple(val(sampleID),path(bam)) from bam_ch;

 output:
 path("${sampleprefix}_header.txt")into header_ch


 script:
 //remove pattern
 sampleprefix=sampleID.replace("${params.replace}", "")
 """
 ##samtools index ${bam}
 printf "${sampleprefix}\t" > ${sampleprefix}_header.txt
 samtools view ${bam} |head -n1|cut -f1 |tr ":" "\t" >> ${sampleprefix}_header.txt
 printf "\n" >> ${sampleprefix}_header.txt
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
