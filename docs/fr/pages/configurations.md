# **Configuration**

!!! tip
    Vous pouvez personnaliser les paramètres du pipeline dans le fichier [`config/config.yaml`](https://forge.ird.fr/transvihmi/nfernandez/GeVarLi/-/blob/main/config/config.yaml).

## **Répertoire des lectures (Reads)**
- **fastq_dir** : Chemin vers les lectures appariées `.fastq.gz` _(par défaut : 'resources/reads/')_ [PATH]

## **Ressources matérielles**
Modifiez ces valeurs pour correspondre à votre machine ou cluster de calcul :
- **cpus** : Nombre maximum de cœurs CPU utilisés en parallèle par les outils multithreadés (ex : BWA, Minimap2) _(par défaut : '8')_ [INT]
- **ram** : Limite de mémoire vive en Go pour les tâches intensives comme le tri Samtools _(par défaut : '16')_ [INT]
- **tmpdir** : Répertoire temporaire pour les calculs _(par défaut : '$TMPDIR')_ [STR]

## **Consensus et Références**
- **path** : Chemin vers les fichiers FASTA de référence _(par défaut : 'resources/genomes/')_ [PATH]
- **reference** : Numéro d'accession NCBI pour téléchargement automatique ou nom de fichier local _(par défaut : 'MN908947' [SARS-CoV-2])_ [STR]
  * _Exemples_ : `'MN908947'` (SARS-CoV-2), `'NC045512'` (SARS-CoV-2), `'AF380138'` (MPXV Zaïre), `'HM045817'` (Chikungunya)
  * _Téléchargement automatique_ : Tout numéro d'accession NCBI valide est téléchargé dynamiquement s'il n'est pas déjà présent.
- **mincov** : Seuil de profondeur minimale de couverture ; les positions sous ce seuil sont masquées par des "N" _(par défaut : '30')_ [INT]
- **minaf** : Fréquence allélique minimale pour l'appel de variants SNV _(par défaut : '0.2')_ [FLOAT]
- **iupac** : Génération de codes d'ambiguïté IUPAC pour les variants intra-hôte _(par défaut : désactivé)_ [OPT]
- **aligner** : Outil d'alignement : **bwa**, **bowtie2** ou **minimap2** _(par défaut : 'bwa')_
- **caller** : Outil d'appel de variants : **ivar** ou **lofreq** _(par défaut : 'ivar')_

## **Nextclade**
- **path** : Chemin vers les répertoires de jeux de données Nextclade _(par défaut : 'resources/nextclade/')_ [PATH]
- **dataset** : Nom du jeu de données Nextclade ciblé _(par défaut : 'sars-cov-2')_ [STR]
  * _Téléchargement automatique_ : GeVarLi télécharge automatiquement les bases Nextclade manquantes via la commande `nextclade dataset get`.

## **Paramètres iVar**
- **min_bq** : Score de qualité de base minimal pour considérer un nucléotide _(par défaut : '20')_ [INT]
- **min_qual** : Seuil minimal de qualité pour l'appel de la base consensus _(par défaut : '20')_ [INT]
- **map_qual** : Score minimal de qualité d'alignement pour l'appel de variants _(par défaut : '20')_ [INT]

## **Bamclipper (Amorces d'amplicons)**
- **path** : Chemin vers les fichiers BEDPE d'amorces _(par défaut : 'resources/primers/bedpe/')_ [PATH]
- **primers** : Schéma d'amorces au format BEDPE _(par défaut : 'SARS-CoV-2_Wuhan_MN-908947-3_artic-primers-V4-1')_ [STR]
- **upstream** : Nombre de bases en amont rognées _(par défaut : '5')_ [INT]
- **downstream** : Nombre de bases en aval rognées _(par défaut : '5')_ [INT]

## **Nettoyage et Contrôle Qualité**
- **Cutadapt** : Retrait des adaptateurs et filtre de taille minimale _(length: '50')_
- **Sickle-trim** : Rognage de qualité par fenêtre glissante _(quality: '30', length: '50')_
- **Fastq-Screen** : Fichier de configuration de dépistage des contaminations (`config/fastq-screen.conf`) et taille de l'échantillonnage _(par défaut : '1000' lectures)_
