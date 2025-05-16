#!/usr/bin/env nextflow

process fastqc{
    publishDir "${params.outdir}/${meta.sample}/fastqc"
  conda (params.enable_conda ? "bioconda::fastqc=0.12.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0"
    } else {
        container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"
    }
   input:
   tuple val(meta), path(reads)

   output:
   tuple val(meta), path("*"), emit: fastqc_reports
   tuple val(meta), path("*zip"), emit: fastqc_zips
   tuple val(meta), path("*html"), emit: fastqc_htmls
   path("*zip"), emit: fastqc_zips_path
   script:
   """
   fastqc ${reads} -t ${task.cpus}
   """
}

process multiqc{
conda (params.enable_conda ? "bioconda::multiqc=1.24" : null)
    if (workflow.containerEngine == 'singularity' && !params.pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/multiqc:1.24--pyhdfd78af_0"
    } else {
        container "quay.io/biocontainers/multiqc:1.24--pyhdfd78af_0"
    }
    publishDir "${params.outdir}/multiqc", mode: "copy"
    input:
    path metric_files
   
    output:
    path "multiqc*", emit: multiqc_reports

    script:
    """
    multiqc .
    """
}

workflow {
   Channel.fromPath(params.samplesheet, checkIfExists: true)
   | splitCsv( header:true )
   | map { row ->
       meta = row.subMap('sample')
       [meta, [
          file(row.fastq_1, checkIfExists: true),
          file(row.fastq_2, checkIfExists: true)]]
   }
   | set { ch_fastq }
   fastqc(ch_fastq)
   multiqc(fastqc.out.fastqc_zips_path.collect())
}
