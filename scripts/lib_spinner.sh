#!/bin/bash

###############################################################################
### SPINNER ###
###############
# Name ___________________ lib_spinner.sh
# Version ________________ v.2025.12
# Author _________________ Nicolas Fernandez
# Affiliation ____________ IRD_U233_TransVIHMI
# Aim ____________________ Run a function with a spinner
# Date ___________________ 2025.09.30
# Latest modifications ___ 2025.12.09
# Use ____________________ 'source lib_spinner.sh && run_with_spinner sleep 10'
###############################################################################

run_with_spinner() (
    # Spinner models:
    #local spinner=( "|" "/" "-" "\\" ) # Simple
    #local spinner=( "←" "↖" "↑" "↗" "→" "↘" "↓" "↙" ) # Arrows
    #local spinner=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" ) # Braille
    #local spinner=( "-[ATGCATGCATGC]-" "-[TGCATGCATGCA]-" "-[GCATGCATGCAT]-" "-[CATGCATGCATG]-" ) # DNA bases (B&W)
    #local spinner=( "[     ]" "[█    ]" "[██   ]" "[███  ]" "[ ███ ]" "[  ███]" "[   ██]" "[    █]" ) # Progress bar
    #local spinner=( "●∙∙∙∙∙" "∙●∙∙∙∙" "∙∙●∙∙∙" "∙∙∙●∙∙" "∙∙∙∙●∙" "∙∙∙∙∙●" "∙∙∙∙●∙" "∙∙∙●∙∙" "∙∙●∙∙∙" "∙●∙∙∙∙" ) # Dots
    #local spinner=( "🌍" "🌎" "🌏" ) # Earth
    #local spinner=( "🌑" "🌒" "🌓" "🌔" "🌕" "🌖" "🌗" "🌘" ) # Moon
    #local spinner=( "🌰" "🌱" "🌿" "☘️" "🍀" "🪴" "🌴" "🍃" "🍂") # Plants
    #local spinner=( "🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚" "🕛" ) # Clock
    #local spinner=( " ☀️ " " 🌤️ " " ⛅ " " ☁️ " " 🌧️ " " 🌨️ " " ⛈️ " " 🌨️ " " 🌧️ " " ☁️ " " ⛅ " " 🌤️ " "🌤️🌈" "🌬️🌤️") # Weather

    # Spinner-specific DNA base colors
    local T="${RED}T${NC}"   # T: Red
    local A="${GREEN}A${NC}" # A: Green
    local G="${YLO}G${NC}"   # G: Yellow
    local C="${BLUE}C${NC}"  # C: Blue
    local spinner=("-[ ${T}${A}${G}${C}${T}${A}${G}${C}${T}${A}${G}${C} ]-"
                   "-[ ${A}${G}${C}${T}${A}${G}${C}${T}${A}${G}${C}${T} ]-"
                   "-[ ${G}${C}${T}${A}${G}${C}${T}${A}${G}${C}${T}${A} ]-"
                   "-[ ${C}${T}${A}${G}${C}${T}${A}${G}${C}${T}${A}${G} ]-")

    # Silent cmd > stdout and stderr
    set +m # 
    ("$@" > /dev/null 2>&1) &
    local pid=$!
    disown $pid 2>/dev/null
    set -m

    # Loop
    local i=0
    printf "\n\n\n\n"
    printf "\033[3A"
    while kill -0 $pid 2>/dev/null; do
        printf "
        \r\033[K Please wait %s " "${spinner[$i]}"
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.1
    done

    wait $pid
    local exit_code=$?
    printf "\r\033[K"

    return ${exit_code}
)
