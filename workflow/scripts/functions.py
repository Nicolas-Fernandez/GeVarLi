###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
###                                                                         ###
###    /\  ______      ___ ____ _  _ __   ____ __   ____     ______  /\     ###
###    ||  \ \ \ \    / __( ___( \/ )__\ (  _ (  ) (_  _)   / / / /  ||     ###
###    ||   > > > >  ( (_-.)__) \  /(__)\ )   /)(__ _)(_   < < < <   ||     ###
###    ||  /_/_/_/    \___(____) \(__)(__(_)\_(____(____)   \_\_\_\  ||     ###
###    \/                                                            \/     ###
###                                                                         ###
###I###R###D######U###2###3###3#######T###R###A###N###S###V###I###H###M###I####
# Name ___________________ functions.py
# Version ________________ v.2025.04
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Snakefile functions
# Date ___________________ 2021.10.12
# Latest modifications ___ 2025.04.04
# Use ____________________ import scripts.functions as functions
###############################################################################
 
###############################################################################
### IMPORTS ###
###############

import os, re, glob, time, sys, subprocess, platform, yaml
from snakemake.io import expand # type: ignore
from collections import defaultdict

###############################################################################
### GLOBAL VARIABLES ###
########################

# Define colors
blue = "\033[1;34m"
green = "\033[1;32m"
red = "\033[1;31m"
ylo = "\033[1;33m"
nc = "\033[0m"

###############################################################################
### FUNCTIONS ###
##################

###############################################################################
# GET_VALID_FASTQ
def get_valid_fastq(fastq_dir):
    fastq_files = glob.glob(os.path.join(fastq_dir, "*.fastq.gz"))
    sample_dict = defaultdict(dict)
    warnings = []
    # Parse
    for fastq in fastq_files:
        basename = os.path.basename(fastq)
        # RegEx
        match = re.search(r"^(?P<sample>.+)_R(?P<mate>[12])", basename)
        if match:
            sample = match.group("sample")
            mate = match.group("mate")
            sample_dict[sample][mate] = fastq
        else:
            warnings.append(f"{red}[WARNING]{nc} File '{basename}' does not match the expected naming pattern. Skipping.")
    # Is paired ?
    valid_fastq = {}
    for sample, mates in sample_dict.items():
        if "1" in mates and "2" in mates:
            valid_fastq[sample] = mates
        else:
            missing = "R1" if "1" not in mates else "R2"
            warnings.append(f"{red}[WARNING]{nc} Sample '{sample}' is incomplete (missing {missing}). Skipping.")
    warnings.append(f"\n{blue}[INFO]{nc} Total valid samples: {len(valid_fastq)}")

    return valid_fastq, warnings

###############################################################################
## GET_BAM_INPUT
def get_bam_input(wildcards):
    markdup = "results/02_Mapping/{sample}_{reference}_{mapper}_markdup.bam"
    if MODULES["clipping"]:
        markdup = "results/02_Mapping/{sample}_{reference}_{mapper}_trimmed-sorted.bam"
    return markdup

###############################################################################
## GET_BAI_INPUT
def get_bai_input(wildcards):
    index = "results/02_Mapping/{sample}_{reference}_{mapper}_markdup.bam.bai"
    if MODULES["clipping"]:
        index = "results/02_Mapping/{sample}_{reference}_{mapper}_trimmed-sorted.bam.bai"
    return index

###############################################################################
## GET_FINAL_OUTPUTS
def get_final_outputs():
    final_outputs = []
    # symlinks
    # quality_controls
    if MODULES["qualities"]:
        final_outputs.append(expand("resources/indexes/fastq-screen/{qc_ref}",
                                qc_ref = QC_REF))
        final_outputs.append(expand("results/00_Quality_Control/fastq-screen/{sample}_R{mate}/",
                                    sample = SAMPLE,
                                    mate = MATE))
        final_outputs.append(expand("results/00_Quality_Control/fastqc/{sample}_R{mate}/",
                                    sample = SAMPLE,
                                    mate = MATE))
    # reads_trimming
    if MODULES["keeptrim"]:
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trim_R1.fastq.gz",
                                    sample = SAMPLE))
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trim_R2.fastq.gz",
                                    sample = SAMPLE))
        final_outputs.append(expand("results/01_Trimming/sickle/{sample}_cutadapt-sickle-trim_SE.fastq.gz",
                                    sample = SAMPLE))
    # genomes_indexing
    # reads_mapping
    # primers_clipping
    if MODULES["clipping"]:
        #final_outputs.append(expand("results/02_Mapping/{sample}_{reference}_{mapper}_trimmed-sorted.bam",
        #                            sample = SAMPLE,
        #                            reference = REFERENCE,
        #                            mapper = MAPPER))
        final_outputs.append(expand("results/02_Mapping/{sample}_{reference}_{mapper}_trimmed-sorted.bam.bai",
                                    sample = SAMPLE,
                                    reference = REFERENCE,
                                    mapper = MAPPER))
    # duplicates_removing
    # coverage_stats
    if MODULES["covstats"]:
        final_outputs.append(expand("results/03_Coverage/{sample}_{reference}_{mapper}_{min_depth}x_coverage-stats.tsv",
                                    sample = SAMPLE,
                                    reference = REFERENCE,
                                    min_depth=MIN_DEPTH,
                                    mapper = MAPPER))
        final_outputs.append(expand("results/03_Coverage/histogram/{sample}_{reference}_{mapper}_coverage-histogram.txt",
                                    sample = SAMPLE,
                                    reference = REFERENCE,
                                    mapper = MAPPER))
        final_outputs.append(expand("results/03_Coverage/flagstat/{sample}_{reference}_{mapper}_flagstat.{ext}",
                                    sample = SAMPLE,
                                    reference = REFERENCE,
                                    mapper = MAPPER,
                                    ext = STAT_EXT))
        final_outputs.append(expand("results/{reference}_{mapper}_{min_depth}x_all-coverage-stats.tsv",
                                    reference = REFERENCE,
                                    mapper = MAPPER,
                                    min_depth = MIN_DEPTH))
    # lowcov_masking
    # variants_calling
    # consensus_calling
    if MODULES["consensus"]:
        final_outputs.append(expand("results/05_Consensus/{sample}_{reference}_{mapper}_{min_depth}x_{caller}_consensus-sequence.fasta",
                                    sample=SAMPLE,
                                    reference=REFERENCE,
                                    mapper = MAPPER,
                                    min_depth=MIN_DEPTH,
                                    caller=CALLER))
        final_outputs.append(expand("results/04_Variants/{sample}_{reference}_{mapper}_{min_depth}x_{caller}_variant-filt.vcf",
                                    sample=SAMPLE,
                                    reference=REFERENCE,
                                    mapper = MAPPER,
                                    min_depth = MIN_DEPTH,
                                    caller = CALLER))
        final_outputs.append(expand("results/{reference}_{mapper}_{min_depth}x_{caller}_all-consensus-sequences.fasta",
                                    reference = REFERENCE,
                                    mapper = MAPPER,
                                    min_depth = MIN_DEPTH,
                                    caller = CALLER))
    # lineages_calling
    if MODULES["lineages"]:
        final_outputs.append(expand("results/06_Lineages/{sample}_{reference}_{mapper}_{min_depth}x_{caller}_{assigner}_report.tsv",
                                    sample=SAMPLE,
                                    reference=REFERENCE,
                                    mapper = MAPPER,
                                    min_depth = MIN_DEPTH,
                                    caller = CALLER,
                                    assigner = ASSIGNER))
        final_outputs.append(expand("results/{reference}_{mapper}_{min_depth}x_{caller}_{assigner}_all-lineages.tsv",
                                    reference = REFERENCE,
                                    mapper = MAPPER,
                                    min_depth = MIN_DEPTH,
                                    caller = CALLER,
                                    assigner = ASSIGNER))
    # return final_outpus
    return final_outputs

###############################################################################
# GET_SETTINGS
def get_settings(config, start_time):
    # Get working directory
    workdir = os.getcwd()

    # Get GeVarLi version
    version_file = os.path.join(workdir, "VERSION.txt")
    try:
        with open(version_file, "r") as vf:
            version = vf.read().strip()
    except Exception:
        version = "N/A"

    # Get 
    shell = os.environ.get("SHELL", "N/A")

    # Get system information
    system_platform = platform.system().lower()
    if "darwin" in system_platform:
        os_type = "osx"
    elif "linux" in system_platform:
        os_type = "linux"
    elif "bsd" in system_platform:
        os_type = "bsd"
    elif "sunos" in system_platform:
        os_type = "solaris"
    elif "windows" in system_platform:
        os_type = "windows"
    else:
        os_type = "unknown (" + system_platform + ")"

    # Get hardware information
    if os_type == "osx":
        try:
            model_name = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"]).decode().strip()
            physical_cpu = subprocess.check_output(["sysctl", "-n", "hw.physicalcpu"]).decode().strip()
            logical_cpu = subprocess.check_output(["sysctl", "-n", "hw.logicalcpu"]).decode().strip()
            mem_size = subprocess.check_output(["sysctl", "-n", "hw.memsize"]).decode().strip()  # en octets
            ram_gb = int(mem_size) // (1024 ** 3)
        except Exception:
            model_name = physical_cpu = logical_cpu = ram_gb = "N/A"
    elif os_type in ["linux", "bsd", "solaris"]:
        try:
            lscpu_out = subprocess.check_output(["lscpu"]).decode()
            model_name = ""
            physical_cpu = ""
            threads_cpu = ""
            for line in lscpu_out.splitlines():
                if "Model name:" in line:
                    model_name = line.split(":", 1)[1].strip()
                if line.startswith("CPU(s):"):
                    physical_cpu = line.split(":", 1)[1].strip()
                if "Thread(s) per core:" in line:
                    threads_cpu = line.split(":", 1)[1].strip()
            if physical_cpu and threads_cpu:
                logical_cpu = int(physical_cpu) * int(threads_cpu)
            else:
                logical_cpu = "N/A"
        except Exception:
            model_name = physical_cpu = logical_cpu = "N/A"
        try:
            with open("/proc/meminfo", "r") as meminfo:
                for line in meminfo:
                    if line.startswith("MemTotal:"):
                        mem_kb = int(re.findall(r'\d+', line)[0])
                        ram_gb = mem_kb // (1024 ** 2)
                        break
        except Exception:
            ram_gb = "N/A"
    else:
        print(f"\nPlease, use a UNIX-like operating system (linux, osx, WSL).")
        sys.exit(0)

    # Get network status
    def is_online():
        for host in ["google.com", "cloudflare.com"]:
            try:
                subprocess.check_call(
                    ["ping", "-c", "1", "-W", "5", host],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return True
            except subprocess.CalledProcessError:
                continue
        return False

    network = "Online" if is_online() else "Offline"

    # Get Conda / Snakemake version
    def get_version(cmd, fallback="N/A"):
        try:
            return subprocess.check_output(cmd).decode().strip()
        except Exception:
            return fallback

    conda_version = get_version(["conda", "--version"])
    mamba_version = get_version(["mamba", "--version"]).splitlines()[0]
    snakemake_version = get_version(["snakemake", "--version"])

    # Get resources
    resources = config.get("resources", {})
    max_threads = resources.get("cpus", "N/A")
    max_memory = resources.get("ram", "N/A")
    tmp_dir = resources.get("tmp_dir", "N/A")

    # Get modules
    modules = config.get("modules", {})
    qualities = modules.get("qualities", "N/A")
    keeptrim = modules.get("keeptrim", "N/A")
    clipping = modules.get("clipping", "N/A")
    covstats = modules.get("covstats", "N/A")
    consensus = modules.get("consensus", "N/A")
    lineages = modules.get("lineages", "N/A")
    gisaid = modules.get("gisaid", "N/A")

    # Get tools
    tools = config.get("tools", {})
    mapper = tools.get("mapper", "N/A")
    caller = tools.get("caller", "N/A")
    assigner = tools.get("assigner", "N/A")

    # Get consensus parameters
    consensus = config.get("consensus", {})
    reference = consensus.get("reference", "N/A")
    min_depth = consensus.get("min_depth", "N/A")
    max_depth = consensus.get("max_depth", "N/A")
    min_freq = consensus.get("min_freq", "N/A")
    min_indel = consensus.get("min_indel", "N/A")
  
    # Get other parameters
    nextclade_dataset = config.get("nextclade", {}).get("dataset", "N/A")
    fastqscreen_subset = config.get("fastq_screen", {}).get("subset", "N/A")
    ivar_clipping = config.get("primers", {}).get("bed", {}).get("scheme", "N/A")
    cutadapt_clipping = config.get("cutadapt", {}).get("clipping", "N/A")

    # Get time stamp
    time_stamp_start = time.strftime("%Y-%m-%d %H:%M", time.localtime(start_time))

    # Définir les listes de samples et warnings formatées
    samples_list = "\n".join(SAMPLE) if SAMPLE else "No samples"
    warnings_list = "\n".join(SAMPLE_WARNINGS) if SAMPLE_WARNINGS else "No warnings"

    # Create message
    message_settings = f"""
    {blue}------------------------------------------------------------------------{nc}
    {blue}#####{nc} {red}About{nc} {blue}#####{nc}
    {blue}-----------------{nc}

    {green}Name{nc} __________________________ GeVarLi
    {green}Version{nc} _______________________ {ylo}{version}{nc}
    {green}Author{nc} ________________________ Nicolas Fernandez
    {green}Affiliation{nc} ___________________ IRD_U233_TransVIHMI
    {green}Aim{nc} ___________________________ {red}Ge{nc}nome assembling, {red}Var{nc}iant calling and {red}Li{nc}neage assignation
    {green}Date{nc} __________________________ 2021.10.12
    {green}Latest modifications{nc} __________ 2025.04.04
    {green}Use{nc} ___________________________ '{ylo}snakemake --use-conda{nc}'


    {blue}------------------------------------------------------------------------{nc}
    {blue}#####{nc} {red}Operating System{nc} {blue}#####{nc}
    {blue}----------------------------{nc}

    {green}Operating system{nc} ______________ {red}{os_type}{nc}
    {green}Shell{nc} _________________________ '{ylo}{shell}{nc}'


    {blue}------------------------------------------------------------------------{nc}
    {blue}#####{nc} {red}Hardware{nc} {blue}#####{nc}
    {blue}--------------------{nc}

                                        {ylo}Brand(R){nc} | {ylo}Type(R){nc} | {ylo}Model{nc} | {ylo}@ Speed GHz{nc}
    {green}Chip Model Name{nc} _______________ {model_name}
    {green}Physical CPUs{nc} _________________ {red}{physical_cpu}{nc}
    {green}Logical CPUs{nc} __________________ {red}{logical_cpu}{nc} threads
    {green}System Memory{nc} _________________ {red}{ram_gb}{nc} Gb of RAM


    {blue}------------------------------------------------------------------------{nc}
    {blue}#####{nc} {red}Configuration{nc} {blue}#####{nc}
    {blue}-------------------------{nc}

    {green}Starting time{nc} _________________ {time_stamp_start}

    {green}Conda version{nc} _________________ {ylo}{conda_version}{nc}
    {green}Mamba version{nc} _________________ {ylo}{mamba_version}{nc}
    {green}Snakemake version{nc} _____________ {ylo}{snakemake_version}{nc}

    {green}Max threads{nc} ___________________ {red}{max_threads}{nc} of {ylo}{logical_cpu}{nc} threads available
    {green}Max memory{nc} ____________________ {red}{max_memory}{nc} Gb of {ylo}{ram_gb}{nc} Gb available
    {green}Temp directory{nc} ________________ '{ylo}{tmp_dir}{nc}'

    {green}Network{nc} _______________________ {red}{network}{nc}

    {green}Working directory{nc} _____________ '{ylo}{workdir}{nc}'
    {green}Fastq directory{nc} _______________ '{ylo}{FASTQ_DIR}{nc}'

    {green}  > Warnings:{nc}

{warnings_list}

    {green}  > Samples list:{nc}

{samples_list}

    {blue}Modules:{nc}
    {green}  > Quality Control{nc} ____________ {ylo}{qualities}{nc}
    {green}  > Keep Trim{nc} __________________ {ylo}{keeptrim}{nc}
    {green}  > Soft Clipping{nc} ______________ {ylo}{clipping}{nc}
    {green}  > Cov Stats{nc} __________________ {ylo}{covstats}{nc}
    {green}  > Consensus{nc} __________________ {ylo}{consensus}{nc}
    {green}  > Lineages{nc} ___________________ {ylo}{lineages}{nc}
    {green}  > Gisaid{nc} _____________________ {ylo}{gisaid}{nc}

    {blue}Tools:{nc}
    {green}  > Mapper{nc} _____________________ {ylo}{mapper}{nc}
    {green}  > Caller{nc} _____________________ {ylo}{caller}{nc}
    {green}  > Assigner{nc} ___________________ {ylo}{assigner}{nc}

    {blue}Params:{nc}
    {green}  > Reference genome{nc} ___________ '{ylo}{reference}{nc}'
    {green}  > Min depth{nc} __________________ {red}{min_depth}{nc}x
    {green}  > Max depth{nc} __________________ {red}{max_depth}{nc}x (0 = no limit)
    {green}  > Min allele frequency{nc} _______ {red}{min_freq}{nc}
    {green}  > Min indel frequency{nc} ________ {red}{min_indel}{nc}

    {green}  > Nextclade dataset{nc} __________ '{ylo}{nextclade_dataset}{nc}'
    {green}  > Fastq-Screen subset{nc} ________ {red}{fastqscreen_subset}{nc} reads/sample
    {green}  > Soft clipping (ivar){nc} _______ '{ylo}{ivar_clipping}{nc}' scheme
    {green}  > Hard clipping (cutadapt){nc} ___ {red}{cutadapt_clipping}{nc} nt
    """

    # Clean message
    ansi_escape = re.compile(r'\x1B\[[0-9;]*[mK]')
    message_clean = ansi_escape.sub('', message_settings)

    # Create log file
    results_dir = os.path.join(workdir, "results", "10_Reports")
    os.makedirs(results_dir, exist_ok=True)

    # Write log file
    log_file = os.path.join(results_dir, "settings.log")
    with open(log_file, "w") as logf:
        logf.write(message_clean)

    # Print message
    print(message_settings)

###############################################################################
# GET_TIME
def get_time(start_time):
        time_stamp_start = time.strftime("%Y-%m-%d %H:%M", time.localtime(start_time))
        time_stamp_end = time.strftime("%Y-%m-%d %H:%M", time.localtime())
        elapsed_time = int(time.time() - start_time)
        hours = elapsed_time // 3600
        minutes = (elapsed_time % 3600) // 60
        seconds = elapsed_time % 60
        formatted_time = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        green = "\033[32m"
        ylo = "\033[33m"
        nc = "\033[0m"
        message_time = f"""
    {green}Start time{nc} _____________ {time_stamp_start}
    {green}End time{nc} _______________ {time_stamp_end}
    {green}Processing time{nc} ________ {ylo}{formatted_time}{nc}
"""
        print(message_time)
        ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')
        message_clean = ansi_escape.sub('', message_time)
        with open("results/10_Reports/time.log", "w") as f:
            f.write(message_clean)

###############################################################################
###############################################################################