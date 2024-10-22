#!/bin/bash

###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ Install_Miniforge3_Conda-Mamba.sh
# Version ________________ v.2024.10
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Miniforge3 distribution for Conda-Mamba installation
# Date ___________________ 2024.09.27
# Latest modifications ___ 2024.09.27 (change old paths from miniconda3 to miniforge3)
# Use ____________________ ./Install_Miniforge3_Conda-Mamba.sh

###############################################################################
### COLORS ###
##############
red="\033[1;31m"   # red
green="\033[1;32m" # green
ylo="\033[1;33m"   # yellow
blue="\033[1;34m"  # blue
nc="\033[0m"       # no color


###############################################################################
### ABOUT ###
#############
workdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd) # Get working directory
gevarli_version="2024.10"                              # GeVarLi version

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Install_Miniforge3_Conda-Mamba.sh
${blue}Version${nc} ________________ ${ylo}${gevarli_version}${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ ${red}Miniforge3${nc} distribution for ${ylo}Conda-Mamba${nc} installation
${blue}Date${nc} ___________________ 2024.09.27
${blue}Latest modifications${nc} ___ 2024.09.27 (Init)
${blue}Run${nc} ____________________ ./Install_Miniforge3_Conda-Mamba.sh
"


###############################################################################
### OPERATING SYSTEM ###
########################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}OPERATING SYSTEM${nc} ${green}#####${nc}
${green}----------------------------${nc}
"

# Get and print operating system 
case "$OSTYPE" in
  darwin*)  os="osx" ;;
  linux*)   os="linux" ;;
  bsd*)     os="bsd" ;;                       
  solaris*) os="solaris" ;;
  msys*)    os="windows" ;;
  cygwin*)  os="windows" ;;
  *)        os="unknown (${OSTYPE})" ;;
esac
echo -e "${blue}Operating system${nc} _______ ${red}${os}${nc}"

# Get and print shell
shell=$SHELL
echo -e "${blue}Shell${nc} __________________ ${ylo}${shell}${nc}"


###############################################################################
### HARDWARE ###
################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}HARDWARE${nc} ${green}#####${nc}
${green}--------------------${nc}
"

if [[ ${os} == "osx" ]]
then
    model_name=$(sysctl -n machdep.cpu.brand_string) # Get chip model name
    physical_cpu=$(sysctl -n hw.physicalcpu)         # Get physical cpu
    logical_cpu=$(sysctl -n hw.logicalcpu)           # Get logical cpu
    mem_size=$(sysctl -n hw.memsize)                 # Get memory size (bit)
    ram_gb=$(expr ${mem_size} \/ $((1024**3)))       # mem_size / 1024**3 = Gb
elif [[ ${os} == "linux" || ${os} == "bsd" || ${os} == "solaris" ]]
then
    model_name=$(lscpu | grep -o -E "Model name: +.+" | sed -E "s/Model name: +//")                           # Get chip model name
    physical_cpu=$(lscpu | grep -o -E "^CPU\(s\): +[0-9]+" | sed -E "s/CPU\(s\): +//")                        # Get physical cpu
    threads_cpu=$(lscpu | grep -o -E "^Thread\(s\) per core: +[0-9]+" | sed -E "s/Thread\(s\) per core: +//") # Get thread(s) per core
    logical_cpu=$(expr ${physical_cpu} \* ${threads_cpu})                                                     # Calcul logical cpu
    mem_size=$(grep -o -E "MemTotal: +[0-9]+" /proc/meminfo | sed -E "s/MemTotal: +//")                       # Get memory size (Kb)
    ram_gb=$(expr ${mem_size} \/ $((1024**2)))                                                                # mem_size / 1024**2 = Gb
else
    echo -e "Please, use UNIX operating systems like '${red}osx${nc}', '${red}linux${nc}' or '${red}WSL${nc}'"
    exit 1
fi

# Print some hardware specifications (maybe wrong with WSL...)
echo -e "                         ${ylo}Brand(R)${nc} | ${ylo}Type(R)${nc} | ${ylo}Model${nc} | ${ylo}@ Speed GHz${nc}
${blue}Chip Model Name${nc} ________ ${model_name}
${blue}Physical CPUs${nc} __________ ${red}${physical_cpu}${nc}
${blue}Logical CPUs${nc} ___________ ${red}${logical_cpu}${nc} threads
${blue}System Memory${nc} __________ ${red}${ram_gb}${nc} Gb of RAM
"


###############################################################################
### NETWORK ###
###############
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}NETWORK${nc} ${green}#####${nc}
${green}-------------------${nc}
"

if curl -s --head --request GET http://www.google.com --max-time 5 > /dev/null || \
   curl -s --head --request GET http://www.cloudflare.com --max-time 5 > /dev/null;
then
    network="Online"
else
    network="Offline"
fi

echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"


###############################################################################
### MINIFORGE3 - CONDA/MAMBA INSTALLATION ###
#############################################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Conda/Mamba - Miniforge3 installation${nc} ${green}#####${nc}
${green}-------------------------------------------------${nc}
"

# Test if a conda distribution already exist
if [[ $(which conda) ]]
then
    echo -e "
${blue}A Conda/Mamba distribution is already install on your computer:${nc}"
    conda --version
    which conda
    echo -e ""
else # Test network conection
    if [[ ${network} = "Online" ]]
    then
        echo -e "
${blue}No Conda/Mamba distribution found.${nc}
${green}Miniforge3${nc} distribution for ${ylo}Conda${nc} and ${ylo}Mamba${nc} will be installed.
"
	if [[ ${os} == "osx" ]]
	then
	    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
            bash ./Miniforge3-MacOSX-x86_64.sh -b -p ~/miniforge3/
            rm -f ./Miniforge3-MacOSX-x86_64.sh
	elif [[ ${os} == "linux" || ${os} == "bsd" || ${os} == "solaris" ]]
        then
	    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
            bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/ 
            rm -f ./Miniforge3-Linux-x86_64.sh
	fi
        ~/miniforge3/condabin/conda update conda --yes
        ~/miniforge3/condabin/mamba init
        ~/miniforge3/condabin/mamba --version
        exit
    else
	echo -e "
${red}No internet available, please check your network conection.${nc}
"
    fi
fi

###############################################################################
