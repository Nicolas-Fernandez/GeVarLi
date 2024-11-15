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
# Name ___________________ Install_Conda-with-Miniforge3.sh
# Version ________________ v.2024.11
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Install Conda with Miniforge3 distribution
# Date ___________________ 2024.09.27
# Latest modifications ___ 2024.11.15 (Lighter)
# Use ____________________ bash ./Install_Conda-with-Miniforge3.sh

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

echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}ABOUT${nc} ${green}#####${nc}
${green}-----------------${nc}

${blue}Name${nc} ___________________ Install_Conda-with-Miniforge3.sh
${blue}Version${nc} ________________ ${ylo}v.2024.11${nc}
${blue}Author${nc} _________________ Nicolas Fernandez
${blue}Affiliation${nc} ____________ IRD_U233_TransVIHMI
${blue}Aim${nc} ____________________ Install ${red}Conda${nc} with ${green}Miniforge3${nc} distribution
${blue}Date${nc} ___________________ 2024.09.27
${blue}Latest modifications${nc} ___ 2024.11.13 (Lighter)
${blue}Run${nc} ____________________ bash ./Install_Conda-with-Miniforge3.sh
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

if ping -c 1 -W 5 google.com > /dev/null 2>&1 || \
   ping -c 1 -W 5 cloudflare.com > /dev/null 2>&1
then
    network="Online"
else
    network="Offline"
fi

echo -e "
${blue}Network${nc} ________________ ${red}${network}${nc}
"


###############################################################################
### INSTALL CONDA WITH MINIFORGE3 DISTRIBUTION ###
##################################################
echo -e "
${green}------------------------------------------------------------------------${nc}
${green}#####${nc} ${red}Install Conda with Miniforge3 distribution${nc} ${green}#####${nc}
${green}------------------------------------------------------${nc}
"

# Test if a conda distribution already exist
if [[ $(command -v conda) ]]
then # If exist, do nothing
    echo -e "
${blue}You already have a Conda distribution.
Your Conda configuration:${nc}
"
    which conda                  # which Conda
    conda --version              # versions
    conda config --show channels # channels
    echo -e ""
else # If not, check network status
    if [[ ${network} = "Offline" ]]
    then # If offline, do nothing
	echo -e "
${red}No Conda distribution found.${nc}

${red}If you want install Conda, please check your network conection.${nc}
"
        exit 1
    else # If online, install miniforge3 (silent mode)
        echo -e "
${red}No Conda distribution found.${nc}

${green}Miniforge3${nc} distribution for ${ylo}Conda${nc} will now be installed, with:
    Channels ___________ '${ylo}conda-forge${nc}' ; '${ylo}bioconda${nc}'
    Channel priority ___ '${ylo}Strict${nc}'

It ensures that the channel priority configured upper is respected when solving dependencies.
"
	if [[ ${os} == "osx" ]]
	then # If OSX
            echo -e "
${blue}>>> Download and install Miniforge3-MacOSX-x86_64.sh${nc}
"
	    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh
	    bash ./Miniforge3-MacOSX-x86_64.sh -b -p ~/miniforge3/ > /dev/null 2>&1
            rm -f ./Miniforge3-MacOSX-x86_64.sh > /dev/null 2>&1
	elif [[ ${os} == "linux" || ${os} == "bsd" || ${os} == "solaris" ]]
        then # If LINUX, BSD or SOLARIS 
            echo -e "
${blue}>>> Download and install Miniforge3-Linux-x86_64.sh${nc}
"
	    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
	    bash ./Miniforge3-Linux-x86_64.sh -b -p ~/miniforge3/ > /dev/null 2>&1
            rm -f ./Miniforge3-Linux-x86_64.sh > /dev/null 2>&1
	fi
	# Then update, show version, init and source
        echo -e "
${blue}>>> Edit your${nc} '${ylo}~/.condarc${nc}' ${blue}file:${nc}
${blue}        Add channels:${nc} '${ylo}conda-forge${nc}' ; '${ylo}bioconda${nc}'
${blue}        Set channel priority:${nc} '${ylo}strict${nc}'
"
	~/miniforge3/condabin/conda config --add channels bioconda        # add 'bioconda' channel
	~/miniforge3/condabin/conda config --add channels conda-forge     # add 'conda-forge' channel
	~/miniforge3/condabin/conda config --set channel_priority strict  # add 'strict' channel priority
	#~/miniforge3/condabin/conda config --set auto_activate_base false  # no conda activation to every new terminal open
	echo -e "
${blue}>>> Update Conda:${nc}
"
	~/miniforge3/condabin/conda update conda --yes # update conda
        echo -e "
${blue}>>> Conda version and channels:${nc}
"
	~/miniforge3/condabin/conda --version              # version
	~/miniforge3/condabin/conda config --show channels # channels
        echo -e "
${blue}>>> Init shell:${nc}
"
        shell=$(~/miniforge3/condabin/conda init 2> /dev/null | grep "modified" | sed 's/modified      //')
	~/miniforge3/condabin/conda init > /dev/null 2>&1 # init shell
        echo -e "

${blue}>>> For changes to take effect, you can either:
               - close and re-open your current shell
               - run:${nc} '${ylo}source ${shell}${nc}'
"
    fi
fi

###############################################################################
