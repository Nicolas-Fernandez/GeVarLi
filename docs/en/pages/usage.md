# **Usage**

## **Quick Start**

### **Standard Analysis**

To run your analysis with GeVarLi:

1. **Place your paired-end FASTQ reads** (in `.fastq.gz` format) into the `resources/reads/` directory:
   ```shell
   mkdir -p resources/reads
   cp /path/to/your/reads/*_R{1,2}*.fastq.gz resources/reads/
   ```

2. **Execute GeVarLi**:
   * **Local workstation**:
     ```shell
     bash Run_GeVarLi.sh
     ```
   * **HPC cluster with Slurm (e.g. IRD i-Trop)**:
     ```shell
     bash run_gevarli_itrop-slurm-hpc.sh
     ```

3. **Monitor and retrieve results**:
   Output files will be generated in `results/`, including consensus sequences, variant calls, coverage metrics, and MultiQC reports.

---

### **Running Built-in Tests**

GeVarLi includes a lightweight, pre-configured SARS-CoV-2 test dataset (< 500 KB) in [`.test/reads/`](file:///Users/2021nf001/git/workflow_snakemake/GeVarLi/.test/reads).

* **Fast dry-run check (DAG resolution)**:
  ```shell
  snakemake -n --config fastq_dir='.test/reads/'
  ```

* **Full test execution with the standard wrapper**:
  ```shell
  mkdir -p resources/reads
  cp .test/reads/* resources/reads/
  bash Run_GeVarLi.sh
  ```

---

## **Amplicon Primers Trimming**

If your library was sequenced with an amplicon-based protocol (such as ARTIC), provide primer coordinates in **BEDPE** format in `resources/primers/bedpe/` to ensure primers are clipped with **Bamclipper**.  
Alternatively, set up hard-clipping using **Cutadapt** in `config/config.yaml`.

---

## **Project Structure**

```shell
🧩 GeVarLi/
│
├── 🖥️ Run_GeVarLi.sh                   # Standard execution script
├── 🖥️ run_gevarli_itrop-slurm-hpc.sh   # Slurm HPC launcher (i-Trop)
├── ⚙️ mkdocs.yaml                      # Documentation configuration
├── 📜 README.md                        # Project overview and badges
├── 📜 CONTRIBUTING.md                  # Community contribution guide
├── 📜 CODE_OF_CONDUCT.md               # Contributor covenant code of conduct
├── 📜 CITATION.cff                     # Citation metadata
├── 📜 CHANGELOG.md                     # Version changelog
├── 🪪 LICENSE                          # GNU AGPLv3 license
├── 🔢 VERSION                          # Version identifier
├── 🚫 .gitignore                       # Ignored files (results, reads)
├── ⚙️ .gitlab-ci.yml                   # CI/CD testing and Pages deployment
│
├── 📂 .gitlab/                         # Issue and MR templates
│   └── 📂 issue_templates/
│       ├── 📄 Bug.md
│       └── 📄 Feature.md
│
├── 📂 .test/                           # Lightweight test datasets (< 500 KB)
│   └── 📂 reads/
│       ├── 📦 SARS-CoV-2_Omicron-BA1_..._R1.fastq.gz
│       └── 📦 SARS-CoV-2_Omicron-BA1_..._R2.fastq.gz
│
├── 📂 config/                          # Workflow configuration
│   ├── ⚙️ config.yaml                  # Main pipeline parameters
│   ├── ⚙️ fastq-screen.conf            # Contamination database settings
│   └── ⚙️ multiqc.yaml                 # MultiQC report template
│
├── 📂 workflow/                        # Snakemake pipeline core
│   ├── 📜 Snakefile                    # Master workflow entry point
│   ├── 📂 envs/                        # Conda software environments
│   │   ├── 🍜 workflow-core.yaml       # Orchestrator environment
│   │   └── 🍜 {TOOL}.yaml              # Tool-specific isolated environments
│   └── 📂 rules/                       # Modular workflow rules
│       ├── 📜 genomes_indexing.smk     # NCBI Entrez fetching and indexing
│       ├── 📜 quality_control.smk      # FastQC and Fastq-Screen rules
│       ├── 📜 reads_trimming.smk       # Cutadapt and Sickle trimming
│       ├── 📜 reads_mapping.smk        # BWA/Minimap2 mapping & Bamclipper
│       ├── 📜 variants_calling.smk     # iVar SNV calling and VCF formatting
│       ├── 📜 consensus_calling.smk    # Masked consensus generation
│       ├── 📜 lineages_calling.smk     # Nextclade dataset fetch and lineage
│       └── 📜 multiqc_reporting.smk    # Aggregated HTML reporting
│
├── 📂 resources/                       # Inputs and databases
│   ├── 📂 reads/                       # Input FASTQ directory (user reads)
│   ├── 📂 genomes/                     # Reference FASTA genomes
│   │   ├── 📂 viruses/                 # On-demand NCBI Entrez fetched references
│   │   └── 📂 fastq-screen/            # QC screening references (PhiX, etc.)
│   ├── 📂 nextclade/                   # On-demand Nextclade lineage datasets
│   └── 📂 primers/                     # Amplicon schemes (BEDPE, BED, FASTA)
│
├── 📂 results/                         # Generated outputs (gitignored)
│   ├── 🧬 All_{REF}_consensus_sequences.fasta
│   ├── 📊 All_{REF}_genome_coverages.tsv
│   ├── 📊 All_{REF}_nextclade_lineages.tsv
│   └── 📂 10_Reports/                  # Execution summary and HTML reports
│
└── 📂 docs/                            # Bilingual web documentation
    ├── 🌐 extra.css
    ├── 📂 images/
    ├── 📂 en/                          # English documentation pages
    └── 📂 fr/                          # French documentation pages
```
