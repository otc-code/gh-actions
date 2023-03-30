aws_config ()
{
    echo -e "${OK}AWS${NC} - Region: ${INF}$region${NC}, Bucket: ${INF}$bucket${NC}, DynamoDB: ${INF}$dynamodb_table${NC}"
    terraform init -reconfigure \
        -backend-config="region=$region" \
        -backend-config="bucket=$bucket" \
        -backend-config="dynamodb_table=$dynamodb_table" \
        -backend-config="key=bootstrap.aws" \
        -backend-config="encrypt=$encrypt" &> /dev/null
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "  * ${INF}Backend${NC}: not configured or accessible, deploying AWS backend."
        cp $SCRIPT_DIRECTORY/terraform/templates/conf.aws.tf.local $SCRIPT_DIRECTORY/terraform/aws/config.tf
        echo "  * Terraform init -reconfigure"
        terraform init -reconfigure &> /dev/null
        echo "  * Create Bootstrap Plan"
        terraform plan -out=bootstrap.plan \
            -var "cloud_region=$region" \
            -var "s3_bucket_name=$bucket" \
            -var "dynamodb_table_name=$dynamodb_table" &> /dev/null
        FILE=bootstrap.plan
        if [ -f "$FILE" ]; then
            echo -e "  * ${OK}Bootstrap${NC}: Planfile $FILE exists."
        else
            echo -e "  * ${ERR}Bootstrap{NC}: Planfile $FILE does NOT exists."
            exit 1
        fi
        echo "  * Apply Bootstrap Plan"
        terraform apply bootstrap.plan
        cp $SCRIPT_DIRECTORY/terraform/templates/conf.aws.tf $SCRIPT_DIRECTORY/terraform/$provider/config.tf
        echo "  * Migrating state to backend."

        terraform init -migrate-state -force-copy \
            -backend-config="region=$region" \
            -backend-config="bucket=$bucket" \
            -backend-config="dynamodb_table=$dynamodb_table" \
            -backend-config="key=bootstrap.aws" \
            -backend-config="encrypt=$encrypt" &> /dev/null
        echo "  * Refreshing backend state."

        echo yes|terraform apply -refresh-only \
            -var "cloud_region=$region" \
            -var "s3_bucket_name=$bucket" \
            -var "dynamodb_table_name=$dynamodb_table" &> /dev/null
        rm $SCRIPT_DIRECTORY/terraform/$provider/terraform.tfstate
    fi
    echo -e "  * ${OK}Backend${NC}: Configured, add prequisites file to deployment"
    if [ -z "$PRQ_FILE" ]; then echo "  * Skipping prequisites_file."
    else
        cp $PRQ_FILE $SCRIPT_DIRECTORY/terraform/$provider/prequisites.tf
        terraform init -upgrade \
            -backend-config="region=$region" \
            -backend-config="bucket=$bucket" \
            -backend-config="dynamodb_table=$dynamodb_table" \
            -backend-config="key=bootstrap.aws" \
            -backend-config="encrypt=$encrypt" &> /dev/null

        terraform apply --auto-approve \
            -var "cloud_region=$region" \
            -var "s3_bucket_name=$bucket" \
            -var "dynamodb_table_name=$dynamodb_table"
    fi
}

aws_config_destroy (){
    cd $SCRIPT_DIRECTORY/terraform/$provider
    cp $SCRIPT_DIRECTORY/terraform/templates/conf.aws.tf $SCRIPT_DIRECTORY/terraform/aws/config.tf
    terraform init -reconfigure \
        -backend-config="region=$region" \
        -backend-config="bucket=$bucket" \
        -backend-config="dynamodb_table=$dynamodb_table" \
        -backend-config="key=bootstrap.aws" \
        -backend-config="encrypt=$encrypt" &> /dev/null
    status=$?

    if [ $status -ne 0 ]; then
        echo "  * Backend not configured!"
        exit 1
    fi

    cp $SCRIPT_DIRECTORY/terraform/templates/conf.aws.tf.local config.tf
    echo "  * Migrating state from remote to local"
    terraform init -migrate-state -force-copy &> /dev/null
    echo "  * terraform destroy"
    terraform destroy --auto-approve \
        -var "cloud_region=$region" \
        -var "s3_bucket_name=$bucket" \
        -var "dynamodb_table_name=$dynamodb_table"
}
