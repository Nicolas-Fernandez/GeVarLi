#!/usr/bin/env python3

import os
import sys
import subprocess
import platform
import re
import glob
import time
import yaml

# Get working directory
workdir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))

# Get version
version_file = os.path.join(workdir, "VERSION.txt")
try:
    with open(version_file, "r") as vf:
        version = vf.read().strip()
except Exception:
    version = "N/A"

# Define colors
blue = "\033[1;34m"
green = "\033[1;32m"
red = "\033[1;31m"
ylo = "\033[1;33m"
nc = "\033[0m"

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

# Get version
def get_version(cmd, fallback="N/A"):
    try:
        return subprocess.check_output(cmd).decode().strip()
    except Exception:
        return fallback

conda_version = get_version(["conda", "--version"])
mamba_version = get_version(["mamba", "--version"]).splitlines()[0]
snakemake_version = get_version(["snakemake", "--version"])

# Get configuration
config_file = os.path.join(workdir, "config", "config.yaml")
with open(config_file, "r") as cf:
    config_data = yaml.safe_load(cf)

# Get fastq directory
fastq_dir = config_data.get("fastq_dir", "")
fastq_files = len(glob.glob(os.path.join(fastq_dir, "*.fastq.gz")))
fastq_R1 = len(glob.glob(os.path.join(fastq_dir, "*R1*.fastq.gz")))
fastq_R2 = len(glob.glob(os.path.join(fastq_dir, "*R2*.fastq.gz")))

# Get resources
resources = config_data.get("resources", {})
max_threads = resources.get("cpus", "N/A")
max_memory = resources.get("ram", "N/A")

# Get modules
modules = config_data.get("modules", {})
qualities = modules.get("qualities", "N/A")
keeptrim = modules.get("keeptrim", "N/A")
cleapping = modules.get("cleapping", "N/A")
covstats = modules.get("covstats", "N/A")
consensus = modules.get("consensus", "N/A")
lineages = modules.get("lineages", "N/A")
gisaid = modules.get("gisaid", "N/A")

# Get consensus parameters
consensus_params = config_data.get("consensus", {})
reference_conf = consensus_params.get("reference", "N/A")
mapper = consensus_params.get("mapper", "N/A")
min_cov = consensus_params.get("min_cov", "N/A")
min_freq = consensus_params.get("min_freq", "N/A")
assigner = consensus_params.get("assigner", "N/A")

# Get other parameters
nextclade_dataset = config_data.get("nextclade", {}).get("dataset", "N/A")
fastqscreen_subset = config_data.get("fastq_screen", {}).get("subset", "N/A")
cutadapt_clipping = config_data.get("cutadapt", {}).get("clipping", "N/A")

# Get time stamp
time_stamp_start = time.strftime("%Y-%m-%d %H:%M", time.localtime())

# Create message
message_settings = f"""{blue}------------------------------------------------------------------------{nc}
{blue}#####{nc} {red}Configuration{nc} {blue}#####{nc}
{blue}-------------------------{nc}

{green}Starting time{nc} ______________ {time_stamp_start}

{green}Conda version{nc} ______________ {ylo}{conda_version}{nc}
{green}Mamba version{nc} ______________ {ylo}{mamba_version}{nc}
{green}Snakemake version{nc} __________ {ylo}{snakemake_version}{nc}

{green}Max threads{nc} ________________ {red}{max_threads}{nc} of {ylo}{logical_cpu}{nc} threads available
{green}Max memory{nc} _________________ {red}{max_memory}{nc} of {ylo}{ram_gb}{nc} Gb available
{green}Jobs memory{nc} ________________ {red}N/A{nc} Gb per job

{green}Network{nc} ____________________ {red}{network}{nc}

{green}Working directory{nc} _________ '{ylo}{workdir}{nc}'

{green}Fastq directory{nc} ___________ '{ylo}{fastq_dir}{nc}'
{green}  > Fastq processed{nc} ________ {red}{fastq_files}{nc} fastq files
{green}  > Forward reads{nc} __________ {red}{fastq_R1}{nc} R1
{green}  > Reverse reads{nc} __________ {red}{fastq_R2}{nc} R2

{blue}Modules:{nc}
{green}  > Quality Control{nc} ________ {red}{qualities}{nc}
{green}  > Keep Trim{nc} ______________ {red}{keeptrim}{nc}
{green}  > Soft Clipping{nc} __________ {red}{cleapping}{nc}
{green}  > Cov Stats{nc} ______________ {red}{covstats}{nc}
{green}  > Consensus{nc} ______________ {red}{consensus}{nc}
{green}  > Lineages{nc} _______________ {red}{lineages}{nc}
{green}  > Gisaid{nc} _________________ {red}{gisaid}{nc}

{blue}Params:{nc}
{green}  > Reference genome{nc} _______ {ylo}{reference_conf}{nc}
{green}  > Mapper{nc} ________________ {ylo}{mapper}{nc}
{green}  > Min coverage{nc} ___________ {red}{min_cov}{nc} X
{green}  > Min allele frequency{nc} ___ {red}{min_freq}{nc}
{green}  > Assigner{nc} ______________ {red}{assigner}{nc}
{green}    - Nextclade dataset{nc} _____ {red}{nextclade_dataset}{nc}
{green}  > Fastq-Screen subset{nc} ____ {red}{fastqscreen_subset}{nc}
{green}  > Cutadapt clipping{nc} ______ {red}{cutadapt_clipping} nt{nc}
"""

# Print message
print(message_settings)

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