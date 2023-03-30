#!/bin/bash

#Color for Outputs
OK='\033[0;32m✓ '
INF='\033[0;33m'
ERR='\033[0;31m✗ '
NC='\033[0m'

mkdir -p $RESULTS_DIR

function hr(){
    for i in {1..125}; do echo -n -; done
    echo ""
}

function show_info(){
    hr
    echo -e "♈ Action: $GITHUB_WORKFLOW with $GITHUB_EVENT_NAME"
    echo -e "♎ Repository: ${INF}$GITHUB_REPOSITORY${NC} on $GITHUB_REF_NAME"
    echo -e "☸ Running script: ${INF}'`basename $0`'${NC} in $SCRIPT_DIRECTORY"
    hr
    echo -e "- TF_DIR: ${INF}$TF_DIR${NC}"

    #TERRAFORM_COMMAND
    if [[ -z "$DEBUG" ]]; then
        DEBUG="false"
        echo -e "Debug: ${INF}Disabled${NC}"
        hr
    else
        echo -e "Debug: ${INF}Enabled${NC}"
        hr
        set -x

    fi

}
