# **Fonctionnalités et outils**

## **Gestion de workflow et infrastructure**
  - Orchestrateur de workflow : Snakemake (version 9.27+)
  - Gestion des environnements : Miniforge / Conda (environnement unifié `workflow-core`)
  - Exécution HPC : Intégration Slurm native pour clusters de calcul (ex : IRD i-Trop)
  - Intégration continue : Validation automatique du DAG Snakemake et compilation stricte de la documentation

## **Gestion des références génomiques**
  - Téléchargement automatisé des références virales : NCBI Entrez efetch (récupération dynamique via numéro d'accession)
  - Téléchargement automatisé des bases de lignées : Nextclade CLI (`nextclade dataset get`)
  - Prise en charge des génomes personnalisés : Intégration transparente de fichiers FASTA utilisateurs dans `resources/genomes/`

## **Contrôle qualité des lectures**
  - Contrôle des contaminations : Fastq-Screen	
  - Mesures de qualité des lectures : FastQC
  - Rapport qualité HTML agrégé : MultiQC
  
## **Nettoyage et filtrage des lectures**
  - Nettoyage des adaptateurs Illumina : Cutadapt
  - Nettoyage des amorces d'amplicons : Cutadapt _('hard-clipping')_
  - Élimination des lectures de basse qualité : Sickle-trim
  
## **Alignement des lectures**
  - Indexation des génomes : BWA _(ou Bowtie2, ou Minimap2)_
  - Alignement des lectures : BWA _(ou Bowtie2, ou Minimap2)_
  - Retrait des amorces d'amplicons : Bamclipper _('soft-clipping')_
  - Rapport de couverture génomique : Bedtools _(fichier tabulaire TSV)_
  - Visualisation : Fichiers BAM, BAI et BED prêts pour IGV
  
## **Appel de variants**
  - Appel des variants : iVar
  - Filtrage des variants : iVar (seuils de fréquence allélique et couverture minimale)
  - Conversion de format : TSV vers format standard VCF
  
## **Séquences consensus**
  - Assemblage du consensus : iVar _(fichier FASTA avec masquage par des "N" sous les seuils de qualité)_
  
## **Classification génomique et lignées**
  - Évaluation de la qualité des génomes : Nextclade
  - Assignation des clades et lignées : Nextclade _(et Pangolin le cas échéant)_

## **Graphes du Workflow**

### Graphe des règles (Rulegraph)
<img src="../../../images/gevarli_rulegraph.png" width="2043" height="3216">

### Graphe des fichiers (Filegraph)
<img src="../../../images/gevarli_filegraph.png" width="2043" height="3882">
