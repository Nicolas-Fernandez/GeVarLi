#!/bin/bash

###############################################################################
### WORKFLOW ###
################
# Name ___________________ lib_workflow.sh
# Version ________________ v.2025.12
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Setup workflow
# Date ___________________ 2025.09.13
# Latest modifications ___ 2025.12.09
# Use ____________________ source lib_workflow.sh
###############################################################################

# Helper function to get checksum based on OS
_get_checksum() {
    local file_path="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        md5 -q "${file_path}"
    else
        md5sum "${file_path}" | awk '{print $1}'
    fi
}

setup_workflow() {
    local env_yaml="workflow/envs/${conda_workflow_env}.yaml"
    local checksum_dir=".gevarli_cache/"
    local checksum_file="${checksum_dir}/${conda_workflow_env}.md5"

    printf "
    [${YLO}INFO${NC}]: Checking Conda environment: '${YLO}${conda_workflow_env}${NC}'...
    "
    mkdir -p "${checksum_dir}"

    if ! conda env list | grep -q "^${conda_workflow_env}\s" # If environment does not exist
    then
        printf "
        [${YLO}INFO${NC}]: Environment does not exist. Attempting to create it...
        "
        if check_network_status # If network is online
        then 
            if run_with_spinner conda env create --file "${env_yaml}" # If succes (0)
            then
                printf "
                [${GREEN}SUCCES${NC}]: Environment created. Saving checksum...
                "
                _get_checksum "${env_yaml}" > "${checksum_file}"
            else # If failure (1)
                printf "
                [${RED}ERROR${NC}]: Environment creation failed. Please check the logs.
                "
                return 1
            fi
        else # If network is offline
            printf "
            [${RED}ERROR${NC}]: Cannot create environment '${YLO}${conda_workflow_env}${NC}' while offline.
            "
            return 1
        fi

    else # If environment exists, check for updates
        local current_checksum=$(_get_checksum "${env_yaml}")
        local stored_checksum=$(cat "${checksum_file}" 2>/dev/null)

        if [[ "${current_checksum}" == "${stored_checksum}" ]] # If checksums match
        then
            printf "
            [${YLO}INFO${NC}]: '${YLO}${conda_workflow_env}${NC}' is up to date.
            "
        else # If checksums do not match
            printf "
            [${YLO}INFO${NC}]: Environment definition has changed. Attempting to update...
            "
            if check_network_status # If network is online
            then
                if run_with_spinner conda env update --name "${conda_workflow_env}" --file "${env_yaml}" --prune # If succes (0)
                then
                    printf "
                    [${GREEN}SUCCES${NC}]: Environment updated. Saving new checksum...
                    "
                    _get_checksum "${env_yaml}" > "${checksum_file}"
                else # If failure (1)
                    printf "
                    [${RED}ERROR${NC}]: Environment update failed. Please check the logs.
                    "
                    return 1
                fi
            else # If network is offline
                printf "
                [${RED}ERROR${NC}]: Cannot update environment '${YLO}${conda_workflow_env}${NC}' while offline.
                "
                return 1
            fi
        fi
    fi
    return 0
}
