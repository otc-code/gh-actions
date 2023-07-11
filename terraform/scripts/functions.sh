#!/bin/bash

#Color for Outputs
OK='\033[0;32m✓ '
INF='\033[0;33m'
ERR='\033[0;31m✗ '
NC='\033[0m'

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
    echo -e "- TERRAFORM_ACTION: ${INF}$TERRAFORM_ACTION${NC}"
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

tfvars(){
    TFVARS=""

    if [[ -z "$TF_VARS_FILE" ]]; then
        echo -e "${INF}$TERRAFORM_ACTION - TFVARS_FILE${NC}: No TFVARS_FILE set!"
    else
        echo -e "${OK}$TERRAFORM_ACTION - TFVARS_FILE${NC}: Customer $TF_VARS_FILE set!"
        TFVARS="$TFVARS-var-file=$TF_VARS_FILE "
    fi
    if [[ -z "$OTC_TF_VARS_FILE" ]]; then
        echo -e "${INF}$TERRAFORM_ACTION - OTC_TFVARS_FILE${NC}: No OTC_TF_VARS_FILE set!${NC}"
    else
        echo -e "${OK}$TERRAFORM_ACTION - OTC_TFVARS_FILE${NC}: OTC $OTC_TF_VARS_FILE set!${NC}"
        TFVARS="$TFVARS-var-file=$OTC_TF_VARS_FILE "
    fi
    if [[ -z "$AUTO_TF_VARS_FILE" ]]; then
        echo -e "${INF}$TERRAFORM_ACTION - AUTO_TF_VARS_FILE${NC}: No AUTO_TF_VARS_FILE set!${NC}"
    else
        echo -e "${OK}$TERRAFORM_ACTION - AUTO_TF_VARS_FILE${NC}: $AUTO_TF_VARS_FILE set!${NC}"
        TFVARS="$TFVARS-var-file=$AUTO_TF_VARS_FILE "
    fi
}

git_push(){
    git config --global user.name github-actions
    git config --global user.email github-actions@github.com

    git diff --exit-code &> OUT.local &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "${OK}git diff:${NC} nothing to commit"
    else
        MESSAGE="terraform $TERRAFORM_ACTION: $GITHUB_EVENT_NAME, $GITHUB_WORKFLOW"
        echo -e "${OK}git status ($GITHUB_REF_NAME):${NC} \n`git status --short`"

        git commit -a -m "terraform $TERRAFORM_ACTION on $GITHUB_EVENT_NAME"
        git push
        if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
            echo -e "  * ${INF}Push rejected${NC}: Local branch not up to date, will pull again !"
            git pull
            git push
            if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
                echo -e "  * ${ERR}Push rejected${NC}: Check github token permission !"
            fi
        else
            echo -e "${OK}git push:${NC} $MESSAGE"
        fi
    fi
}

function gha_warn(){
    text=$2
    text="${text//'%'/'%25'}"
    text="${text//$'\n'/'%0A'}"
    text="${text//$'\r'/'%0D'}"
    if [[ ! -z "$GITHUB_EVENT_NAME" ]]; then echo "::warning title=$1::$text"; fi
}

function gha_notice(){
    text=$2
    text="${text//'%'/'%25'}"
    text="${text//$'\n'/'%0A'}"
    text="${text//$'\r'/'%0D'}"
    if [[ ! -z "$GITHUB_EVENT_NAME" ]]; then echo "::notice title=$1::$text"; fi
}

function get_backend_provider(){

    if [[ -z "$TF_PARTIAL_BACKEND_FILE" ]]; then
        echo -e "${ERR}Error: No terraform backend config file provided. Abort"
        exit 1
    fi

    eval $(sed -r '/[^=]+=[^=]+/!d;s/\s+=\s/=/g' "$TF_PARTIAL_BACKEND_FILE")
    backend="Unkown provider backend"
    if [ -z "$region" ]; then backend_aws="false"; else backend="aws"; fi
    if [ -z "$resource_group_name" ]; then backend_azr="false"; else backend="azr"; fi
    if [ -z "$prefix" ]; then backend_gcp="false"; else backend="gcp"; fi
    echo -n
    if [[ "$backend" == "Unkown provider backend" ]]; then
        echo -e "${ERR}${TERRAFORM_ACTION}${NC}: Terraform backend Provider ${ERR}$backend - only aws,azr,gcp are supported!{NC}"
    else
        echo -e "${OK}${TERRAFORM_ACTION}${NC}: Terraform backend Provider ${INF}$backend${NC}"
    fi
}

configure_backend_provider(){
    case $backend in
        aws)
            rpl 'backend "local" {}' 'backend "s3" {}' $SCRIPT_DIRECTORY/backend.tpl/aws/conf.tf &> /dev/null
            source "$SCRIPT_DIRECTORY/backend_aws.sh"
            aws_config
            echo -e "${OK}$TERRAFORM_ACTION${NC}: AWS Backend configured."
            if [[ "$BACKEND_DESTROY" == "true" ]]; then
                echo -e "${ERR}AWS Destroy${NC}: Destroy the backend!"
                aws_config_destroy
            fi
            ;;
        azr)
            rpl 'backend "local" {}' 'backend "azurerm" {}' $SCRIPT_DIRECTORY/backend.tpl/azr/conf.tf &> /dev/null
            echo -e "${OK}$TERRAFORM_ACTION${NC}: AzureRM Backend configured."
            source "$SCRIPT_DIRECTORY/backend_azure.sh"
            azure_config
            echo -e "${OK}$TERRAFORM_ACTION${NC}: Azure Backend configured."
            if [[ "$BACKEND_DESTROY" == "true" ]]; then
                echo -e "${ERR}Azure Destroy${NC}: Destroy the backend!"
                azure_config_destroy
            fi
            ;;
        gcp)
            rpl 'backend "local" {}' 'backend "gcs" {}' $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.tf &> /dev/null
            source "$SCRIPT_DIRECTORY/backend_gcp.sh"
            echo -e "${OK}$TERRAFORM_ACTION${NC}:${NC} gcs Backend configured."
            source "$SCRIPT_DIRECTORY/backend_gcp.sh"
            gcp_config
            echo -e "${OK}$TERRAFORM_ACTION${NC}: GCP Backend configured."
            if [[ "$BACKEND_DESTROY" == "true" ]]; then
                echo -e "${ERR}GCP Destroy${NC}: Destroy the backend!"
                gcp_config_destroy
            fi
            ;;
        *)
            echo -e "${ERR}TERRAFORM_ACTION${NC}: Could not configure Backend."
            exit 1
            ;;
    esac
}

get_providers(){
    grep "hashicorp/aws" $TF_DIR/*.tf &>/dev/null
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "${INF}${TERRAFORM_ACTION}${NC}: Amazon Web Service provider not found."
        AWS="false"
    else
        echo -e "${OK}${TERRAFORM_ACTION}${NC}: Amazon Web Service provider found."
        AWS="true"
    fi
    grep "hashicorp/azurerm" $TF_DIR/*.tf &>/dev/null
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "${INF}${TERRAFORM_ACTION}${NC}: Azure RM provider not found."
        AZR="false"
    else
        echo -e "${OK}${TERRAFORM_ACTION}${NC}: Azure RM provider found."
        AZR="true"
    fi
    grep "hashicorp/google" $TF_DIR/*.tf &>/dev/null
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "${INF}${TERRAFORM_ACTION}${NC}: Google provider not found."
        GCP="false"
    else
        echo -e "${INF}${TERRAFORM_ACTION}${NC}: Google provider not found."
        GCP="true"
    fi
    # echo "AWS=$AWS" >> "$GITHUB_OUTPUT"
    # echo "AZR=$AZR" >> "$GITHUB_OUTPUT"
    # echo "GCP=$AWS" >> "$GITHUB_OUTPUT"
}
