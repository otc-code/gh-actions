azure_config ()
{
    PLAN_FILE=$SCRIPT_DIRECTORY/backend.tpl/azr/bootstrap.local
    echo -e "${OK}Azure${NC} - location: ${INF}$CLOUD_REGION${NC}, RG: ${INF}$resource_group_name${NC}, SA: ${INF}$storage_account_name${NC} - $container"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr init -reconfigure \
        -backend-config="resource_group_name=$resource_group_name" \
        -backend-config="storage_account_name=$storage_account_name" \
        -backend-config="container_name=$container_name" \
        -backend-config="key=bootstrap.azure" &> /dev/null
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "${INF}* Backend${NC}: not configured or accessible, deploying Azure backend."
        cp $SCRIPT_DIRECTORY/backend.tpl/azr/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/azr/conf.tf
        echo -e "${OK}${NC}Terraform init -reconfigure"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr init -reconfigure &> /dev/null
        echo -e "${OK}${NC}Create Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr plan -out=$PLAN_FILE \
            -var "cloud_region=$CLOUD_REGION" \
            -var "resource_group_name=$resource_group_name" \
            -var "storage_account_name=$storage_account_name" \
            -var "container_name=$container_name"  &> /dev/null

        if [ -f "$PLAN_FILE" ]; then
            echo -e "${OK}Bootstrap${NC}: Planfile $FILE exists."
        else
            echo -e "${ERR}Bootstrap{NC}: Planfile $FILE does NOT exists."
            exit 1
        fi
        echo -e "${OK}${NC} Apply Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr apply $PLAN_FILE
        rpl 'backend "local" {}' 'backend "azurerm" {}' $SCRIPT_DIRECTORY/backend.tpl/azr/conf.tf &> /dev/null
        echo -e "${OK}${NC} Migrating state to backend."

        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr init -migrate-state -force-copy \
            -backend-config="resource_group_name=$resource_group_name" \
            -backend-config="storage_account_name=$storage_account_name" \
            -backend-config="container_name=$container_name" \
            -backend-config="key=bootstrap.azure" &> /dev/null
        echo -e "${OK}${NC} Refreshing backend state."

        echo yes|terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr -refresh-only \
            -var "cloud_region=$CLOUD_REGION" \
            -var "resource_group_name=$resource_group_name" \
            -var "storage_account_name=$storage_account_name" \
            -var "container_name=$container_name" &> /dev/null
        rm $SCRIPT_DIRECTORY/backend.tpl/azr/terraform.tfstate
    fi
}

azure_config_destroy (){
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr init -reconfigure \
        -backend-config="resource_group_name=$resource_group_name" \
        -backend-config="storage_account_name=$storage_account_name" \
        -backend-config="container_name=$container_name" \
        -backend-config="key=bootstrap.azure" &> /dev/null
    status=$?

    if [ $status -ne 0 ]; then
        echo -e "${ERR}Backend destroy${NC}: Backend not configured!"
        exit 1
    fi

    cp $SCRIPT_DIRECTORY/backend.tpl/azr/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/azr/conf.tf
    echo -e "${OK}${NC} Migrating state from remote to local"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr init -migrate-state -force-copy &> /dev/null
    echo -e "${OK}${NC} terraform destroy"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/azr destroy --auto-approve \
        -var "cloud_region=$CLOUD_REGION" \
        -var "resource_group_name=$resource_group_name" \
        -var "storage_account_name=$storage_account_name" \
        -var "container_name=$container_name"
}
