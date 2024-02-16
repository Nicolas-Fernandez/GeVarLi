#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __| ___| \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__|_)\_|____|____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ SLAM.sh : SLURM Lightweight Automated Manager
# Version ________________ v.2024.02
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Sbatch script for iTROP HPC GeVarLi SLURM submission
# Date ___________________ 2024.02.14
# Latest modifications ___ 2024.02.16
# Use ____________________ bash SLAM.sh

###############################################################################

# Get user
user=$(whoami)

# Usage
usage() {
    echo "
    SLAM: SLURM Lightweight Automated Manager
    
    Usage: $0 [-p partition] [-c cpu] [-m mem] [-i infiniband] [-n name] [-d data] [-h help] [-u usage] [-v version]

    Options:
      -p, --partition=partition   partition requested: short, normal, long, highmem, supermem, gpu
      -c, --cpus-per-task=ncpus   number of cpus required per task [INT]
      -m, --mem=MB                minimum amount of real memory [INT]
      -i, --infiniband            specify --constraint=infiniband (exclud -b)
      -b, --beast                 specify --constraint=beast (exclud -i)
      -n, --name=jobname          name of job (--job-name) [STR]
      -d, --data                  path to data
          --mail-user=user        who to send email notification for job state
          --mail-type=type        notify on state change: BEGIN, END, FAIL or ALL
      -h, --help                  show this help message and exit
      -u, --usage                 display brief usage message and exit
      -v, --version               output version information and exit
    "
    exit 1
}

# Version
version="2024.02"
version() {
    echo "
    SLAM: SLURM Lightweight Automated Manager - V.${version}
    "
    exit 1
}

# Default options
partition="short"
cpu="12"
mem="64"
infiniband=""
ib=""
beast=""
bst=""
name="GeVarLi"
project="/projects/large/GorillaSIVmeta/GeVarLi/"
mail_user="nicolas.fernandez@ird.fr"
mail_type="ALL"

# Parse options
while [[ ${#} -gt 0 ]]; do
    case ${1} in
        -p|--partition)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                partition="${2}"
                shift 2
            else
                echo "
    Error: Argument missing for --partition option
    Try './SLAM.sh --help' for more informations
                " >&2
                exit 1
            fi
            ;;
        -c|--cpus-per-task)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                cpu="${2}"
                shift 2
            else
                echo "
    Error: Argument missing for --cpus-per-task option
    Try './SLAM.sh --help' for more informations
                " >&2
                exit 1
            fi
            ;;
        -m|--mem)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                mem="${2}"
                shift 2
            else
                echo "
    Error: Argument missing for --mem option
    Try './SLAM.sh --help' for more informations
                " >&2
		exit 1
            fi
            ;;
        -i|--infiniband)
            infiniband="--constraint=infiniband"
	    ib="-ib"
            shift
            ;;
        -b|--beast)
            beast="--constraint=BEAST"
	    bst="-bst"
            shift
            ;;
        -n|--name)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                name="${2}"
                shift 2
            else
                echo "
    Error: Argument missing for --name option
    Try './SLAM.sh --help' for more informations
                " >&2
		exit 1
            fi
	    ;;
        -d|--data)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                data="${2}"
                shift 2
            else
                echo "
    Error: Argument missing for --data option
    Try './SLAM.sh --help' for more informations
                " >&2
		exit 1
            fi
            ;;
        --mail-user)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                 mail_user="${2}"
                 shift 2
            else
                echo "
    Error: Argument missing for --mail-user option
    Try './SLAM.sh --help' for more informations
                " >&2
            fi
	    ;;
        --mail-type)
            if [[ -n ${2} && ! ${2} == -* ]]; then
                 mail_type="${2}"
                 shift 2
            else
                echo "
    Error: Argument missing for --mail-type option
    Try './SLAM.sh --help' for more informations
                " >&2
		exit 1
            fi
            ;;
        -h|--help)
            usage
            ;;
        -u|--usage)
            usage
            ;;
        -v|--version)
            version
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "
    Invalid option: ${1}
    Try './SLAM.sh --help' for more informations
            " >&2
	    exit 1
            ;;
    esac
done

# Main script
echo "
    SLAM: SLURM Lightweight Automated Manager
"

# Partition validation if partition provided
if [ -n "${partition}" ]; then
    allowed_partitions=("short" "normal" "long" "highmem" "supermem" "gpu")
    if [[ "${allowed_partitions[@]}" =~ "${partition}" ]]; then
        echo "Setting partition to: ______ ${partition}"
    else
        echo "
    Invalid partition option: ${partition}
    Try './SLAM.sh --help' for more informations
        "
        exit 1
    fi
fi

# CPU validation if cpu per task provided
if [ -n "${cpu}" ]; then
    if [[ "${cpu}" =~ ^[0-9]+$ ]] && [ "${cpu}" -gt 0 ]; then
        echo "Setting CPUs Nb to: ________ ${cpu}"
    else
        echo "
    Invalid CPU value: ${cpu}
    Try './SLAM.sh --help' for more informations
        "
        exit 1
    fi
fi


# MEM validation if  mem provided
if [ -n "${mem}" ]; then
    if [[ "${mem}" =~ ^[0-9]+$ ]] || [ "${mem}" -lt 1 ]; then
        echo "Setting memory MB to: ______ ${mem}"
    else
        echo "
    Invalid memory value: ${mem}
    Try './SLAM.sh --help' for more informations
        "
        exit 1
    fi
fi

# Path validation if project provided
if [ -n "${project}" ]; then
    if [ -d "${project}" ]; then
        echo "Setting project to: ________ ${project}"
    else
	echo "
    Path to project '${project}' does not exist
    Try './SLAM.sh --help' for more informations
    "
        exit 1
    fi
fi

# Mail-user validation if email-user provided
if [ -n "${mail_user}" ]; then
    if [[ "${mail_user}" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$ ]]; then
        echo "Setting mail-user to: ______ ${mail_user}"
    else
        echo "
    Invalid mail-user: ${mail_user}
    Try './SLAM.sh --help' for more informations
        "
        exit 1
    fi
fi

# Mail-type validation if email-type provided
if [ -n "${mail_type}" ]; then
    allowed_type=("BEGIN" "END" "FAIL" "ALL")
    if [[ "${allowed_type[@]}" =~ "${mail_type}" ]]; then
        echo "Setting mail-type to: ______ ${mail_type}"
    else
        echo "
    Invalid mail-type: ${mail_type}
    Try './SLAM.sh --help' for more informations
        "
        exit 1
    fi
fi
    

# Generate SLURM script dynamically
echo "
    Generation: dyna-slurm_${name}_${partition}-${cpu}-${mem}${ib}${bst}.sh
"

cat > dyna-slurm_${name}_${partition}-${cpu}-${mem}${ib}${bst}.sh <<EOF
#!/bin/bash

###############################################################################
### Slurm Configuration ###
###########################

#SBATCH --partition ${partition} --cpus-per-task ${cpu} --mem ${mem} ${infiniband} ${beast}
#SBATCH --job-name=${name}
#SBATCH --mail-user=${mail_user}
#SBATCH --mail-type=${mail_type}

###############################################################################
### Script ###
##############

# CREATE SCRATCH FOLDER
mkdir -p /scratch/${user}_${name}_\${SLURM_JOB_ID}/

# TRANSFER DATA
rsync -a san${ib}:/${project}/ /scratch/${user}_${name}_\${SLURM_JOB_ID}/

# MODULE

# ANALYSIS
bash /scratch/${user}_${name}_\${SLURM_JOB_ID}/Start_GeVarLi.sh

# TRANSFER RESULTS
rsync -a /scratch/${user}_${name}_\${SLURM_JOB_ID}/ san${ib}:/${project}

# DELETE SCRATCH FOLDER
rm -rf /scratch/${user}_${name}_\${SLURM_JOB_ID}/

EOF

# Sbatch run (optional, comment if you wan't)
sbatch dyna-slurm_${name}_${partition}-${cpu}-${mem}${ib}${bst}.sh
