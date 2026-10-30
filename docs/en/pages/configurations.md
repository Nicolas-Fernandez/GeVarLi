# **Configuration**

!!! tip
    You can customize default pipeline settings in the [`config/config.yaml`](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/blob/main/config/config.yaml) file.

## **Reads Directory**
- **fastq_dir**: Path to paired-end `.fastq.gz` reads _(default: 'resources/reads/')_ [PATH]

## **Hardware Resources**
Edit to match your workstation or HPC cluster allocation:
- **cpus**: Maximum CPU cores used in parallel by multi-threaded tools (e.g. BWA, Minimap2) _(default: '8')_ [INT]
- **ram**: Memory ceiling in GB for intensive tasks like Samtools sorting _(default: '16')_ [INT]
- **tmpdir**: Temporary directory for scratch operations _(default: '$TMPDIR')_ [STR]

## **Consensus and References**
- **path**: Path to viral reference FASTA files _(default: 'resources/genomes/')_ [PATH]
- **reference**: Accession number for automated NCBI download or local filename _(default: 'MN908947' [SARS-CoV-2])_ [STR]
  * _Examples_: `'MN908947'` (SARS-CoV-2), `'NC045512'` (SARS-CoV-2), `'AF380138'` (MPXV Zaire), `'HM045817'` (Chikungunya)
  * _Automatic fetching_: Any standard NCBI accession number is dynamically retrieved if not already present.
- **mincov**: Minimum read depth threshold; positions with lower coverage are masked with "N" _(default: '30')_ [INT]
- **minaf**: Minimum allele frequency threshold for SNV variant calling _(default: '0.2')_ [FLOAT]
- **iupac**: Output IUPAC ambiguity codes for intra-host variants _(default: deactivate)_ [OPT]
- **aligner**: Read mapper: **bwa**, **bowtie2**, or **minimap2** _(default: 'bwa')_
- **caller**: Variant caller: **ivar** or **lofreq** _(default: 'ivar')_

## **Nextclade**
- **path**: Path to Nextclade dataset directories _(default: 'resources/nextclade/')_ [PATH]
- **dataset**: Nextclade target dataset name _(default: 'sars-cov-2')_ [STR]
  * _Automatic fetching_: GeVarLi automatically downloads datasets using `nextclade dataset get` if missing.

## **iVar Parameters**
- **min_bq**: Minimum base quality score to consider a base _(default: '20')_ [INT]
- **min_qual**: Minimum quality threshold for consensus base calling _(default: '20')_ [INT]
- **map_qual**: Minimum mapping quality score for variant calling _(default: '20')_ [INT]

## **Bamclipper (Amplicon Primers)**
- **path**: Path to primer BEDPE files _(default: 'resources/primers/bedpe/')_ [PATH]
- **primers**: Primer scheme identifier in BEDPE format _(default: 'SARS-CoV-2_Wuhan_MN-908947-3_artic-primers-V4-1')_ [STR]
- **upstream**: Number of upstream bases for primer clipping _(default: '5')_ [INT]
- **downstream**: Number of downstream bases for primer clipping _(default: '5')_ [INT]

## **Reads Quality and Trimming**
- **Cutadapt**: Adapter removal and minimum length filter _(length: '50')_
- **Sickle-trim**: Sliding window quality trimming _(quality: '30', length: '50')_
- **Fastq-Screen**: Contamination screening configuration file (`config/fastq-screen.conf`) and sampling subset size _(default: '1000' reads)_
