# **Utilisation**

## **Démarrage rapide**

### **Analyse standard**

Pour lancer vos analyses avec GeVarLi :

1. **Placez vos lectures FASTQ appariées** (au format `.fastq.gz`) dans le répertoire `resources/reads/` :
   ```shell
   mkdir -p resources/reads
   cp /chemin/vers/vos/lectures/*_R{1,2}*.fastq.gz resources/reads/
   ```

2. **Exécutez GeVarLi** :
   * **Sur station de travail locale** :
     ```shell
     bash Run_GeVarLi.sh
     ```
   * **Sur cluster de calcul HPC avec Slurm (ex : IRD i-Trop)** :
     ```shell
     bash run_gevarli_itrop-slurm-hpc.sh
     ```

3. **Consultez les résultats** :
   Les fichiers produits sont générés dans `results/`, incluant les séquences consensus, les tableaux de couverture, l'appel de variants et le rapport MultiQC.

---

### **Exécuter les tests intégrés**

GeVarLi inclut un jeu de données de test officiel et ultra-léger (< 500 Ko) dans [`.test/reads/`](file:///Users/2021nf001/git/workflow_snakemake/GeVarLi/.test/reads).

* **Test rapide à blanc (Dry-run / Résolution du DAG)** :
  ```shell
  snakemake -n --config fastq_dir='.test/reads/'
  ```

* **Exécution complète du test avec le script wrapper** :
  ```shell
  mkdir -p resources/reads
  cp .test/reads/* resources/reads/
  bash Run_GeVarLi.sh
  ```

---

## **Rognage des amorces d'amplicons**

Si vos banques ont été produites avec un protocole à base d'amplicons (comme ARTIC), fournissez les coordonnées des amorces au format **BEDPE** dans `resources/primers/bedpe/` pour qu'elles soient retirées via **Bamclipper**.  
Il est également possible de configurer un rognage direct via **Cutadapt** dans `config/config.yaml`.

---

## **Arborescence du projet**

```shell
🧩 GeVarLi/
│
├── 🖥️ Run_GeVarLi.sh                   # Script d'exécution standard
├── 🖥️ run_gevarli_itrop-slurm-hpc.sh   # Lanceur Slurm pour cluster HPC (i-Trop)
├── ⚙️ mkdocs.yaml                      # Configuration de la documentation
├── 📜 README.md                        # Présentation générale et badges
├── 📜 CONTRIBUTING.md                  # Guide de contribution
├── 📜 CODE_OF_CONDUCT.md               # Charte de bonne conduite
├── 📜 CITATION.cff                     # Métadonnées de citation
├── 📜 CHANGELOG.md                     # Historique des versions
├── 🪪 LICENSE                          # Licence GNU AGPLv3
├── 🔢 VERSION                          # Numéro de version
├── 🚫 .gitignore                       # Fichiers exclus du suivi Git
├── ⚙️ .gitlab-ci.yml                   # Validation CI/CD et déploiement Pages
│
├── 📂 .gitlab/                         # Modèles de tickets et Merge Requests
│   └── 📂 issue_templates/
│       ├── 📄 Bug.md
│       └── 📄 Feature.md
│
├── 📂 .test/                           # Jeux de données tests légers (< 500 Ko)
│   └── 📂 reads/
│       ├── 📦 SARS-CoV-2_Omicron-BA1_..._R1.fastq.gz
│       └── 📦 SARS-CoV-2_Omicron-BA1_..._R2.fastq.gz
│
├── 📂 config/                          # Configuration du workflow
│   ├── ⚙️ config.yaml                  # Paramètres principaux du pipeline
│   ├── ⚙️ fastq-screen.conf            # Paramètres de dépistage des contaminations
│   └── ⚙️ multiqc.yaml                 # Modèle de rapport MultiQC
│
├── 📂 workflow/                        # Cœur du pipeline Snakemake
│   ├── 📜 Snakefile                    # Point d'entrée principal
│   ├── 📂 envs/                        # Définition des environnements Conda
│   │   ├── 🍜 workflow-core.yaml       # Environnement de l'orchestrateur
│   │   └── 🍜 {TOOL}.yaml              # Environnements isolés par outil
│   └── 📂 rules/                       # Règles Snakemake modulaires
│       ├── 📜 genomes_indexing.smk     # Téléchargement NCBI et indexation
│       ├── 📜 quality_control.smk      # Règles FastQC et Fastq-Screen
│       ├── 📜 reads_trimming.smk       # Rognage Cutadapt et Sickle
│       ├── 📜 reads_mapping.smk        # Alignement BWA/Minimap2 & Bamclipper
│       ├── 📜 variants_calling.smk     # Appel de variants iVar et format VCF
│       ├── 📜 consensus_calling.smk    # Assemblage du consensus masqué
│       ├── 📜 lineages_calling.smk     # Téléchargement Nextclade et lignées
│       └── 📜 multiqc_reporting.smk    # Agrégation des rapports MultiQC
│
├── 📂 resources/                       # Données d'entrée et bases de données
│   ├── 📂 reads/                       # Répertoire des FASTQ utilisateurs
│   ├── 📂 genomes/                     # Fichiers FASTA de référence
│   │   ├── 📂 viruses/                 # Références NCBI téléchargées à la demande
│   │   └── 📂 fastq-screen/            # Références de contrôle qualité (PhiX...)
│   ├── 📂 nextclade/                   # Datasets Nextclade récupérés à la demande
│   └── 📂 primers/                     # Schémas d'amorces (BEDPE, BED, FASTA)
│
├── 📂 results/                         # Fichiers de résultats (exclus de Git)
│   ├── 🧬 All_{REF}_consensus_sequences.fasta
│   ├── 📊 All_{REF}_genome_coverages.tsv
│   ├── 📊 All_{REF}_nextclade_lineages.tsv
│   └── 📂 10_Reports/                  # Synthèse d'exécution et rapports HTML
│
└── 📂 docs/                            # Documentation web bilingue
    ├── 🌐 extra.css
    ├── 📂 images/
    ├── 📂 en/                          # Pages de documentation en anglais
    └── 📂 fr/                          # Pages de documentation en français
```
