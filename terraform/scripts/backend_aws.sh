aws_config ()
{
    PLAN_FILE=$SCRIPT_DIRECTORY/backend.tpl/aws/bootstrap.local
    echo -e "${OK}AWS${NC} - Region: ${INF}$region${NC}, Bucket: ${INF}$bucket${NC}, DynamoDB: ${INF}$dynamodb_table${NC}"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws init -reconfigure \
        -backend-config="region=$region" \
        -backend-config="bucket=$bucket" \
        -backend-config="dynamodb_table=$dynamodb_table" \
        -backend-config="key=bootstrap.aws" \
        -backend-config="encrypt=$encrypt" #&> /dev/null
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "${INF}* Backend${NC}: not configured or accessible, deploying AWS backend."
        cp $SCRIPT_DIRECTORY/backend.tpl/aws/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/aws/conf.tf
        echo -e "${OK}${NC}Terraform init -reconfigure"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws init -reconfigure &> /dev/null
        echo -e "${OK}${NC}Create Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws plan -out=$PLAN_FILE \
            -var "cloud_region=$region" \
            -var "s3_bucket_name=$bucket" \
            -var "dynamodb_table_name=$dynamodb_table" #&> /dev/null

        if [ -f "$PLAN_FILE" ]; then
            echo -e "${OK}Bootstrap${NC}: Planfile $FILE exists."
        else
            echo -e "${ERR}Bootstrap{NC}: Planfile $FILE does NOT exists."
            exit 1
        fi
        echo -e "${OK}${NC} Apply Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws apply $PLAN_FILE
        rpl 'backend "local" {}' 'backend "s3" {}' $SCRIPT_DIRECTORY/backend.tpl/aws/conf.tf &> /dev/null
        echo -e "${OK}${NC} Migrating state to backend."

        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws init -migrate-state -force-copy \
            -backend-config="region=$region" \
            -backend-config="bucket=$bucket" \
            -backend-config="dynamodb_table=$dynamodb_table" \
            -backend-config="key=bootstrap.aws" \
            -backend-config="encrypt=$encrypt" &> /dev/null
        echo -e "${OK}${NC} Refreshing backend state."

        echo yes|terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws -refresh-only \
            -var "cloud_region=$region" \
            -var "s3_bucket_name=$bucket" \
            -var "dynamodb_table_name=$dynamodb_table" &> /dev/null
        rm $SCRIPT_DIRECTORY/backend.tpl/aws/terraform.tfstate
    fi
}

aws_config_destroy (){
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws init -reconfigure \
        -backend-config="region=$region" \
        -backend-config="bucket=$bucket" \
        -backend-config="dynamodb_table=$dynamodb_table" \
        -backend-config="key=bootstrap.aws" \
        -backend-config="encrypt=$encrypt" &> /dev/null
    status=$?

    if [ $status -ne 0 ]; then
        echo -e "${ERR}Backend destroy${NC}: Backend not configured!"
        exit 1
    fi

    cp $SCRIPT_DIRECTORY/backend.tpl/aws/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/aws/conf.tf
    echo -e "${OK}${NC} Migrating state from remote to local"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws init -migrate-state -force-copy &> /dev/null
    echo -e "${OK}${NC} terraform destroy"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/aws destroy --auto-approve \
        -var "cloud_region=$region" \
        -var "s3_bucket_name=$bucket" \
        -var "dynamodb_table_name=$dynamodb_table"
}
