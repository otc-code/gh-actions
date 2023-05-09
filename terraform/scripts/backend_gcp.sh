gcp_config ()
{
    PLAN_FILE=$SCRIPT_DIRECTORY/backend.tpl/gcp/bootstrap.local
    echo -e "${OK}GCP${NC} - Region: ${INF}$CLOUD_REGION${NC}, Bucket: ${INF}$bucket${NC}, prefix: ${INF}$prefix${NC} project:  ${INF}$GCP_PROJECT_ID${NC}"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp init -reconfigure \
        -backend-config="bucket=$bucket" \
        -backend-config="prefix=bootstrap.gcp" &> /dev/null
    status=$?
    if [ $status -ne 0 ]; then
        echo -e "${INF}* Backend${NC}: not configured or accessible, deploying GCP backend."
        cp $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.tf
        echo -e "${OK}${NC}Terraform init -reconfigure"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp init -reconfigure &> /dev/null
        echo -e "${OK}${NC}Create Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp plan -out=$PLAN_FILE \
            -var "cloud_region=$CLOUD_REGION" \
            -var "gcp_project=$GCP_PROJECT_ID" \
            -var "bucket_name=$bucket" &> /dev/null
        if [ -f "$PLAN_FILE" ]; then
            echo -e "${OK}Bootstrap${NC}: Planfile $FILE exists."
        else
            echo -e "${ERR}Bootstrap{NC}: Planfile $FILE does NOT exists."
            exit 1
        fi
        echo -e "${OK}${NC} Apply Bootstrap Plan"
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp apply $PLAN_FILE
        rpl 'backend "local" {}' 'backend "gcs" {}' $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.tf &> /dev/null
        echo -e "${OK}${NC} Migrating state to backend."
        terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp init -migrate-state -force-copy \
                -backend-config="bucket=$bucket" \
                -backend-config="prefix=bootstrap.gcp" &> /dev/null
        echo -e "${OK}${NC} Refreshing backend state."

        echo yes|terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp -refresh-only \
                -var "cloud_region=$CLOUD_REGION" \
                -var "gcp_project=$GCP_PROJECT_ID" \
                -var "bucket_name=$bucket" &> /dev/null
        rm $SCRIPT_DIRECTORY/backend.tpl/gcp/terraform.tfstate
    fi
}

gcp_config_destroy (){
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp init -reconfigure \
    -backend-config="bucket=$bucket" \
    -backend-config="prefix=bootstrap.gcp" &> /dev/null
    status=$?

    if [ $status -ne 0 ]; then
        echo -e "${ERR}Backend destroy${NC}: Backend not configured!"
        exit 1
    fi

    cp $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.local.tpl $SCRIPT_DIRECTORY/backend.tpl/gcp/conf.tf
    echo -e "${OK}${NC} Migrating state from remote to local"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp init -migrate-state -force-copy &> /dev/null
    echo -e "${OK}${NC} terraform destroy"
    terraform -chdir=$SCRIPT_DIRECTORY/backend.tpl/gcp destroy --auto-approve \
    -var "cloud_region=$CLOUD_REGION" \
    -var "gcp_project=$GCP_PROJECT_ID" \
    -var "bucket_name=$bucket" #&> /dev/null
}