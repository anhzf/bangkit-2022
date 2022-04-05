#! /bin/bash

# Challenge Lab for: https://www.cloudskillsboost.google/focuses/10603 Part 1

if [ -z $DEVSHELL_PROJECT_ID ]; then
  read -p "Enter Project ID: " project_id
else
  printf "Detected project id using: ${DEVSHELL_PROJECT_ID}\n"
  read -p "Enter Project ID [Press enter to skip]: " project_id
  project_id=${project_id:-DEVSHELL_PROJECT_ID}
fi

read -p "Enter Region: " region
read -p "Enter Zone: " zone

printf "\nTask 1: Create development VPC manually\n"
# Create a VPC called griffin-dev-vpc with the following subnets only:
# - griffin-dev-wp | IP address block: 192.168.16.0/20
# - griffin-dev-mgmt | IP address block: 192.168.32.0/20
gcloud compute networks create griffin-dev-vpc --subnet-mode custom
gcloud compute networks subnets create griffin-dev-wp \
  --network=griffin-dev-vpc \
  --range=192.168.16.0/20 \
  --region=$region
gcloud compute networks subnets create griffin-dev-mgmt \
  --network=griffin-dev-vpc \
  --range=192.168.32.0/20 \
  --region=$region
printf "\nTask 1 DONE! Check your progress! \n"

printf "\nTask 2: Create production VPC manually\n"
# Create a VPC called griffin-prod-vpc with the following subnets only:
# - griffin-prod-wp | IP address block: 192.168.48.0/20
# - griffin-prod-mgmt | IP address block: 192.168.64.0/20
gcloud compute networks create griffin-prod-vpc --subnet-mode custom
gcloud compute networks subnets create griffin-prod-wp \
  --network=griffin-prod-vpc \
  --range=192.168.48.0/20 \
  --region=$region
gcloud compute networks subnets create griffin-prod-mgmt \
  --network=griffin-prod-vpc \
  --range=192.168.64.0/20 \
  --region=$region
printf "\nTask 2 DONE! Check your progress! \n"

printf "\nTask 3: Create bastion host\n"
# Create a bastion host with two network interfaces,
# one connected to griffin-dev-mgmt and the other connected to griffin-prod-mgmt.
# Make sure you can SSH to the host.
gcloud compute instances create bastion \
  --machine-type=n1-standard-1 \
  --network-interface=network=griffin-dev-vpc,subnet=griffin-dev-mgmt \
  --network-interface=network=griffin-prod-vpc,subnet=griffin-prod-mgmt \
  --zone=$zone \
  --tags=bastion-host
gcloud compute firewall-rules create bastion-ssh-dev \
  --allow tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=bastion-host \
  --network=griffin-dev-vpc
gcloud compute firewall-rules create bastion-ssh-prod \
  --allow tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=bastion-host \
  --network=griffin-prod-vpc
printf "\nTask 3 DONE! Check your progress! \n"

printf "\nTask 4: Create and configure Cloud SQL Instance\n"
read -p "Enter Password for your Root User: " root_password
# Create a MySQL Cloud SQL Instance called griffin-dev-db in us-east1
gcloud sql instances create griffin-dev-db \
  --tier=db-f1-micro \
  --region=us-east1
  --root-password=$root_password
printf "Created database with root password=$root_password\n"
printf "Connecting to the sql instance...\n"
printf "Please run the query given in instructions!\n"
sleep 5
gcloud sql connect griffin-dev-db --user=root
printf "\nTask 4 DONE! Check your progress! \n"

printf "\nTask 5: Create Kubernetes cluster\n"
# Create a 2 node cluster (n1-standard-4) called griffin-dev, in the griffin-dev-wp subnet, and in zone us-east1-b.
gcloud container clusters create griffin-dev \
  --num-nodes=2 \
  --machine-type=n1-standard-4 \
  --network=griffin-dev-vpc \
  --subnetwork=griffin-dev-wp \
  --zone=us-east1-b
gcloud containers clusters get-credentials griffin-dev --zone=us-east1-b
printf "\nTask 5 DONE! Check your progress! \n"

printf "\nTask 6: Prepare the Kubernetes cluster\n"
gsutil cp -r gs://cloud-training/gsp321/wp-k8s/ .
printf "\nYou will be editing the following files to configure your WordPress Server\n"
printf "Please edit your database username to 'wp_user' and password to 'stormwind_rules'."
printf "\nEditing wp-env.yaml...\n"
sleep 5
nano ./wp-k8s/wp-env.yaml
kubectl create -f ./wp-k8s/wp-env.yaml
printf "\nConfigure the service account..."
gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json
printf "\nTask 6 DONE! Check your progress! \n"

printf "\nTask 7: Create a WordPress deployment\n"
printf "\nYou will be editing the following files to configure your WordPress Deployment\n"
printf "Please replace the YOUR_SQL_INSTANCE to your Cloud SQL instance name."
printf "\nEditing wp-deployment.yaml...\n"
sleep 5
nano ./wp-k8s/wp-deployment.yaml
kubectl apply -f ./wp-k8s/wp-deployment.yaml
kubectl apply -f ./wp-k8s/wp-service.yaml
printf "\nTask 7 DONE! Check your progress! \n"

printf "\nTask 8: Enable monitoring\n"
printf "SKIPPED\n"

printf "\nTask 9: Provide access for an additional engineer\n"
read -p "Enter Project ID [$DEVSHELL_PROJECT_ID]: " project_id
project_id=${project_id:-DEVSHELL_PROJECT_ID}
read -p "Enter Engineer's email address: " engineer_email
gcloud projects add-iam-policy-binding $project_id \
    --member="user:$engineer_email" \
    --role="roles/editor"

printf "\nThere is 'Task 8' that we can't handle. So, please do it yourself and Goodluck!\n"
