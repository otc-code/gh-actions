
azure_config ()
{
    echo -e "  * ${OK}Azure${NC} - location: ${INF}$CLOUD_REGION${NC}, RG: ${INF}$resource_group_name${NC}, SA: ${INF}$storage_account_name${NC} - $container"
    cd $SCRIPT_DIRECTORY/terraform/azure
    cp $SCRIPT_DIRECTORY/terraform/templates/conf.azure.tf config.tf
    terraform init -reconfigure \
        -backend-config="resource_group_name=$resource_group_name" \
        -backend-config="storage_account_name=$storage_account_name" \
        -backend-config="container_name=$container_name" \
        -backend-config="key=bootstrap.azure" &> /dev/null
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "  * ${INF}Backend${NC}: not configured or accessible, deploying Azure backend."
        cp $SCRIPT_DIRECTORY/terraform/templates/conf.azure.tf.local config.tf
        echo "  * Terraform init -reconfigure"
        terraform init -reconfigure &> /dev/null
        echo "  * Create Bootstrap Plan"
        terraform plan -out=bootstrap.plan \
            -var "cloud_region=$CLOUD_REGION" \
            -var "resource_group_name=$resource_group_name" \
            -var "storage_account_name=$storage_account_name" \
            -var "container_name=$container_name"  &> /dev/null

        FILE=bootstrap.plan
        if [ -f "$FILE" ]; then
            echo -e "  * ${OK}Bootstrap${NC}: Planfile $FILE exists."
        else
            echo -e "  * ${ERR}Bootstrap{NC}: Planfile $FILE does NOT exists."
            exit 1
        fi
        echo "  * Apply Bootstrap Plan"
        terraform apply bootstrap.plan
        cp $SCRIPT_DIRECTORY/terraform/templates/conf.azure.tf config.tf
        echo "  * Migrating state to backend."

        terraform init -migrate-state -force-copy \
            -backend-config="resource_group_name=$resource_group_name" \
            -backend-config="storage_account_name=$storage_account_name" \
            -backend-config="container_name=$container_name" \
            -backend-config="key=bootstrap.azure" &> /dev/null
        echo "  * Refreshing backend state."

        echo yes|terraform apply -refresh-only \
            -var "cloud_region=$CLOUD_REGION" \
            -var "resource_group_name=$resource_group_name" \
            -var "storage_account_name=$storage_account_name" \
            -var "container_name=$container_name" &> /dev/null
        rm $SCRIPT_DIRECTORY/terraform/$provider/terraform.tfstate
    fi
    echo -e "  * ${OK}Backend${NC}: Configured, add prequisites file to deployment"
    if [ -z "$PRQ_FILE" ]; then echo "  * Skipping prequisites_file."
    else
        cp $PRQ_FILE $SCRIPT_DIRECTORY/terraform/$provider/prequisites.tf
        terraform init -upgrade \
            -backend-config="resource_group_name=$resource_group_name" \
            -backend-config="storage_account_name=$storage_account_name" \
            -backend-config="container_name=$container_name" \
            -backend-config="key=bootstrap.azure" &> /dev/null

        terraform apply --auto-approve \
            -var "cloud_region=$CLOUD_REGION" \
            -var "resource_group_name=$resource_group_name" \
            -var "storage_account_name=$storage_account_name" \
            -var "container_name=$container_name"
    fi
}

azure_config_destroy (){
    cd $SCRIPT_DIRECTORY/terraform/$provider
    cp $SCRIPT_DIRECTORY/terraform/templates/conf.azure.tf config.tf
    terraform init -reconfigure \
        -backend-config="resource_group_name=$resource_group_name" \
        -backend-config="storage_account_name=$storage_account_name" \
        -backend-config="container_name=$container_name" \
        -backend-config="key=bootstrap.azure" &> /dev/null
    status=$?

    if [ $status -ne 0 ]; then
        echo "  * Backend not configured!"
        exit 1
    fi

    cp $SCRIPT_DIRECTORY/terraform/templates/conf.azure.tf.local config.tf
    echo "  * Migrating state from remote to local"
    terraform init -migrate-state -force-copy &> /dev/null
    echo "  * terraform destroy"
    terraform destroy --auto-approve \
        -var "cloud_region=$CLOUD_REGION" \
        -var "resource_group_name=$resource_group_name" \
        -var "storage_account_name=$storage_account_name" \
        -var "container_name=$container_name"
}
