########################################################################################################################
# Deploy new Customer:

SCRIPT_DIRECTORY=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIRECTORY/functions.sh"
show_info "$@"

# Terraform functions
function version(){
    echo -e "${OK}Terraform:${NC} `which terraform` - `terraform --version -json | jq -r '.terraform_version'`"
}

function fmt(){
    echo -e "${OK}Terraform fmt${NC}"
    terraform -chdir=$TF_DIR fmt
    git_push
}

function fmt_check(){
    terraform -chdir=$TF_DIR fmt -check
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        echo -e "${ERR}Error: terraform format check failed!${NC}"
        #junit_add_fail "terraform fmt" "Terraform format not valid" "`cat ./OUT.local`"
    else
        echo -e "${OK}Terraform fmt check:${NC} successful!"
        #junit_add_ok "format is ok."
    fi
}
function init(){
    git config --global credential.helper 'store'
    git config --global --add url."https://$GITHUB_TOKEN:x-oauth-basic@github".insteadOf ssh://git@github
    git config --global --add url."https://$GITHUB_TOKEN:x-oauth-basic@github".insteadOf https://github
    git config --global --add url."https://$GITHUB_TOKEN:x-oauth-basic@github".insteadOf git@github
    if [[ ! -f "$TF_BACKEND_FILE" ]]; then
        terraform -chdir=$TF_DIR init -reconfigure
    else
        terraform -chdir=$TF_DIR init -reconfigure -backend-config=$TF_BACKEND_FILE
    fi
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        git config --global --unset-all url."https://$GITHUB_TOKEN:x-oauth-basic@github".insteadOf
        echo -e "${ERR}Error: terraform init failed!${NC}"
        echo -e "  ${ERR}Possibly missing GITHUB_TOKEN!${NC}"
        exit 1
    else
        git config --global --unset-all url."https://$GITHUB_TOKEN:x-oauth-basic@github".insteadOf
        echo -e "${OK}Terraform init:${NC} successful!"
    fi
}
function validate(){
    terraform -chdir=$TF_DIR validate -json > tmp.local
    result=`jq '.valid' tmp.local`
    errors=`jq '.error_count' tmp.local`
    warnings=`jq '.warning_count' tmp.local`

    rm tmp.local
    if [ ! "$errors" == 0 ]; then
        echo -e "${ERR}$TERRAFORM_ACTION${NC}: terraform validate failed!${NC}"
        exit 1
    fi
    if [ ! "$warnings" == 0 ]; then
        echo -e "${INF}$TERRAFORM_ACTION${NC}: terraform validate has warnins!${NC}"
        gha_warn "$TERRAFORM_ACTION" "Terraform $TERRAFORM_ACTION: terraform init has warnings!"
    fi
    if [[ "$result" == "true" ]]; then
        echo -e "${OK}$TERRAFORM_ACTION${NC}: terraform validate success!${NC}"
    fi
}
########################################################################################################################
# compliance functions
function compliance()
{
    RESULTS_DIR="$TF_DIR/.results"
    if [[ ! -d "$RESULTS_DIR" ]]; then
        mkdir $RESULTS_DIR
    fi
    tfvars
    mkdir -p ~/.tflint.d
    if [[ -f "$TF_DIR/.tflint.hcl" ]]; then
        echo -e "${INF}$TERRAFORM_ACTION-tflint${NC}: Using custom config in $TF_DIR/.tflint.hcl !${NC}"
        TFLINT_CONFIG="$TF_DIR/.tflint.hcl"
    else
        TFLINT_CONFIG="$SCRIPT_DIRECTORY/tflint.hcl"
        echo -e "${INF}$TERRAFORM_ACTION-tflint${NC}: Using standard tflint.hcl !${NC}"
    fi
    cd $TF_DIR
    tflint --force -c $TFLINT_CONFIG $TFVARS -f junit > "$RESULTS_DIR/tflint.junit.xml"
    cd $SCRIPT_DIRECTORY
}
########################################################################################################################
# security functions
function security()
{
    RESULTS_DIR="$TF_DIR/.results"
    if [[ ! -d "$RESULTS_DIR" ]]; then
        mkdir $RESULTS_DIR
    fi
    tfvars
    cd $TF_DIR
    LOG_LEVEL=error checkov -d . --download-external-modules false -o junitxml > "$RESULTS_DIR/checkov.junit.xml"
    cd $SCRIPT_DIRECTORY
}

function plan(){
    tfvars
    echo -e "${OK}$TERRAFORM_ACTION${NC}: running terraform plan $TFVARS${NC}"
    terraform -chdir=$TF_DIR plan $TFVARS -input=false -out $TF_DIR/tf.plan
    terraform -chdir=$TF_DIR show -json $TF_DIR/tf.plan > $TF_DIR/tf.plan.json.local
    terraform show -no-color plan.local > $TF_DIR/plan.out.local
    STDOUT=$(cat $TF_DIR/plan.out.local)
    # We need to strip the single quotes that are wrapping it so we can parse it with JQ
    plan=$(cat $TF_DIR/tf.plan.json.local | sed "s/^'//g" | sed "s/'$//g")
    # Get the count of the number of resources being created
    create=$(echo "$plan" | jq -r ".resource_changes[].change.actions[]" | grep "create" | wc -l | sed 's/^[[:space:]]*//g')
    # Get the count of the number of resources being updated
    update=$(echo "$plan" | jq -r ".resource_changes[].change.actions[]" | grep "update" | wc -l | sed 's/^[[:space:]]*//g')
    # Get the count of the number of resources being deleted
    delete=$(echo "$plan" | jq -r ".resource_changes[].change.actions[]" | grep "delete" | wc -l | sed 's/^[[:space:]]*//g')
    echo -e "  * ${OK}Terraform plan:${NC} ${OK}$create to add${NC}, ${INF}$update to change${NC} and ${ERR}$delete to delete${NC}!"

    if [ $delete -ne 0 ];  then
        gha_warn "Deleted resources" "This plan will delete resources!"
    fi


    gha_notice "Terraform plan" "Terraform plan: $create to add, $update to change, $delete to destroy."
}

function create_backend(){
    get_backend_provider
    configure_backend_provider

}

$TERRAFORM_ACTION