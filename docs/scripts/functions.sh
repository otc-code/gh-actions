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
    echo -e "- FILE: ${INF}$FILE${NC}"
    if [[ -z "$DEBUG" ]]; then
        DEBUG="false"
        echo -e "Debug: ${INF}Disabled${NC}"
        hr
    else
        echo -e "Debug: ${INF}Enabled${NC}"
        hr
        set -x

    fi
    if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
        echo -e "  * ${INF}PULL_REQUEST${NC}: Readme will not updated on PR!"
        exit 0
    fi
    if [[ "$GITHUB_EVENT_NAME" == "release" ]]; then
    echo -e "  * ${INF}RELEASE${NC}: Updates will happen on main branch!"
    git checkout main
    fi
}

get_github_info(){
    STATUS="draft"
    VERSION="$GITHUB_REF_NAME"
    DATE="` date +"%d.%m.%Y"`"
    if [[ "$GITHUB_REF_NAME" == "main" ]]; then
      STATUS="approved"
    fi
    if [[ "$GITHUB_EVENT_NAME" == "release" ]]; then
      STATUS="released"
    fi
  }

check_markers(){
    grep "$START" "$FILE" > /dev/null
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "  * ${INF}Update README${NC}: $START not found in $FILE, skipping."
        exit 0
    fi

    grep "$END" "$FILE" &> /dev/null
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "  * ${INF}Update README${NC}: $END not found in $FILE, skipping."
        exit 0
    fi
}

git_push(){
    git config --global user.name github-actions
    git config --global user.email github-actions@github.com

    git diff --exit-code &> OUT.local &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "${OK}git diff:${NC} nothing to commit"
    else
        echo -e "${OK}git status ($GITHUB_REF_NAME):${NC} \n`git status --short`"
        MESSAGE="docs: update Header/Footer - $GITHUB_EVENT_NAME, $GITHUB_WORKFLOW"
        echo -e "${OK}git commit ($GITHUB_REF_NAME):${NC} $MESSAGE"
        
        git commit $FILE -m "$MESSAGE"
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
    if [[ "$GITHUB_EVENT_NAME" == "release" ]]; then
      git push --delete origin :$GITHUB_REF
      git tag --delete $GITHUB_REF_NAME
      git tag GITHUB_REF_NAME
      git push
      
    fi
}
