#!/bin/bash

###############################################################################
### SPINNER ###
###############

# Run function with a spinner
run_with_spinner() {
    # Silent cmd > stdout et stderr)
    ("$@" > /dev/null 2>&1) &
    local pid=$!
    disown $pid 2>/dev/null

    # Spinner models
    #local spinner=( "|" "/" "-" "\\" ) # Simple
    #local spinner=( "←" "↖" "↑" "↗" "→" "↘" "↓" "↙" ) # Arrows
    #local spinner=( "🌑" "🌒" "🌓" "🌔" "🌕" "🌖" "🌗" "🌘" ) # Moon
    #local spinner=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" ) # Braille
    #local spinner=( "🕐" "🕑" "🕒" "🕓" "🕔" "🕕" "🕖" "🕗" "🕘" "🕙" "🕚" "🕛" ) # Clock
    local spinner=( "-[ATGCATGCATGC]-" "-[TGCATGCATGCA]-" "-[GCATGCATGCAT]-" "-[CATGCATGCATG]-" ) # DNA bases
    #local spinner=( "[     ]" "[█    ]" "[██   ]" "[███  ]" "[ ███ ]" "[  ███]" "[   ██]" "[    █]" ) # Progress bar
    #local spinner=( "●∙∙∙∙∙" "∙●∙∙∙∙" "∙∙●∙∙∙" "∙∙∙●∙∙" "∙∙∙∙●∙" "∙∙∙∙∙●" "∙∙∙∙●∙" "∙∙∙●∙∙" "∙∙●∙∙∙" "∙●∙∙∙∙" ) # Dots

    # Loop
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r\033[K Please wait %s \n" "${spinner[$i]}"
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.1
    done

    wait $pid
    local exit_code=$?
    printf "\r\033[K"

    # Success or Error ?
    #if [ $exit_code -eq 0 ]; then
    #    echo "${green}[SUCCESS]${nc} Job done (${green}✔${nc})"
    #else
    #    echo "${red}[ERROR]${nc} Job failed (${red}✖${nc})"
    #fi

    return ${exit_code}
}