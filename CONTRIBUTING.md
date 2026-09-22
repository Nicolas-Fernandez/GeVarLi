# Contributing to GeVarLi

Thank you for your interest in contributing to **GeVarLi** (**GE**nome assembly, **VAR**iant calling and **LI**neage assignation)! We welcome contributions from the global genomics, virology, and bioinformatics communities.

---

## Code of Conduct

This project is governed by our [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold these standards of respect and collaboration.

---

## How Can I Contribute?

### 1. Reporting Bugs

Before opening an issue, please search existing issues to avoid duplicates.

When submitting a bug report:
* Describe the bug clearly with steps to reproduce it.
* Provide details on your environment (OS, CPU architecture, Conda/Mamba version, Snakemake version).
* Provide relevant logs (found under `results/10_Reports/tools-log/` or `.snakemake/log/`).
* Specify the virus reference and primer scheme used.

### 2. Adding a New Virus Reference Genome

To add support for a new viral pathogen:
1. Place the reference genome in FASTA format into `resources/genomes/` (named e.g. `<ACCESSION>.fasta`).
2. Update `config/config.yaml` under `consensus: reference:` with the new accession code or file path.
3. If applicable, provide the corresponding annotation (GFF/GBK) for lineage or variant calling modules.

### 3. Adding a New Amplicon Primer Scheme

To add support for a new amplicon sequencing kit:
1. Place the primer scheme BED file into `resources/primers_schemes/bed/<kit_name>/<version>/<scheme>.primer.bed`.
2. Ensure the BED coordinate system matches your reference sequence.
3. Update `config/config.yaml` under `primers: bed: scheme:`.

### 4. Code Contributions & Snakemake Rules

1. **Fork or create a feature branch**:
   ```bash
   git checkout -b feature/my-new-feature
   ```
2. **Follow GeVarLi Standards**:
   * Rules must be modular and placed in `workflow/rules/`.
   * Conda environments must be pinned and placed in `workflow/envs/` using `nodefaults` and channels `conda-forge`, `bioconda`.
   * Follow the standard directory hierarchy (`results/01_Trimming/`, `results/02_Mapping/`, etc.).
   * Never commit raw FASTQ files, large index files, or local analysis outputs.
3. **Verify locally**:
   ```bash
   # Run Snakemake dry-run on test dataset
   snakemake --directory .test/ --snakefile workflow/Snakefile --dry-run
   ```
4. **Submit a Merge Request**:
   * Open a Merge Request on [IRD-Forge](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/merge_requests).
   * Describe your modifications, motivations, and testing steps.

---

## License

By contributing to GeVarLi, you agree that your contributions will be licensed under the [GNU AGPLv3 License](LICENSE).
