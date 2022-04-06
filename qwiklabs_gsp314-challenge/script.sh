#! /bin/bash

# GSP314  | https://www.cloudskillsboost.google/focuses/10417

if [ -z $DEVSHELL_PROJECT_ID ]; then
  read -p "Enter Project ID: " project_id
else
  printf "Detected project id using: ${DEVSHELL_PROJECT_ID}\n"
  read -p "Enter Project ID [Press enter to skip]: " project_id
  project_id=${project_id:-DEVSHELL_PROJECT_ID}
fi

REGION=us-east1
ZONE=$REGION-b
INSTANCE_TYPE=n1-standard-1

gcloud config set compute/zone $ZONE

printf "\n-------------------------------------------------------\n"
printf "Task 2: Setup the Admin instance\n"
# You need to set up an admin machine for the team to use.
# - Once you create the kraken-prod-vpc, you will need to add an instance called $instance_name ,
#   a network interface in kraken-mgmt-subnet and another in kraken-prod-subnet.
# - You need to monitor Instance Name and if CPU utilization is over $threshold
#   for more than a minute you need to send an email to yourself, as admin of the system.
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  read -p "Enter Instance Name: " instance_name
  gcloud compute instances create $instance_name \
    --zone $ZONE \
    --machine-type $INSTANCE_TYPE \
    --network-interface subnet=kraken-mgmt-subnet,network=kraken-mgmt-vpc \
    --network-interface subnet=kraken-prod-subnet,network=kraken-prod-vpc
  EMAIL=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
  cat << EOF > ./channel.json
{
  "type": "email",
  "displayName": "Alert notifications",
  "description": "An address to send email",
  "labels": {
    "email_address": "$EMAIL"
  },
}
EOF
  gcloud beta monitoring channels create --channel-content-from-file="./channel.json"
  CHANNEL=$(gcloud beta monitoring channels list --format="value(name)")
  read -p "Enter CPU threshold (in decimal): " threshold
  cat << EOF > ./alert.json
{
  "combiner":"OR",
  "conditions":[
    {
      "conditionThreshold": {
        "aggregations": [
          {
            "alignmentPeriod":"60s",
            "perSeriesAligner":"ALIGN_MEAN"
          }
        ],
        "comparison":"COMPARISON_GT",
        "duration": "60s",
        "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" metric.label.\"instance_name\"=\"$instance_name\"",
        "thresholdValue": $threshold,
        "trigger":{
          "count":1
        }
      },
      "displayName":"GCE VM Instance - CPU utilization for kraken-admin"
    }
  ],
  "displayName":"kraken-admin",
  "enabled":true,
  "notificationChannels":[
    "$CHANNEL"
  ]
}
EOF
  gcloud alpha monitoring policies create --policy-from-file="./alert.json"
  printf "\nTask 2 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 3: Verify the Spinnaker deployment\n"
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  # The previous architect set up Spinnaker in kraken-build-vpc.
  # Please connect to the Spinnaker console and verify that the built resources are working.

  # To access the Spinnaker console use Cloud Shell and kubectl to port forward the spin-deck pod from port 9000 to 8080
  # and then use Cloud Shell's web preview.

  # You must test that a change to the source code will result in the automated deployment of the new build.
  # You should pull the sample-app repository to make the changes. Make sure you push a new, updated, tag.
  CLUSTER_NAME=spinnaker-tutorial
  gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION
  deck_pod=$(kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward --namespace default $deck_pod 8080:9000 >> /dev/null &
  gcloud source repos clone sample-app
  cd ./sample-app
  git config --global user.email "$(gcloud config get-value core/account)"
  git config --global user.name "$(whoami)"
  git add .
  git commit -a -m "Set project ID"
  git tag v2.0.0
  git push --tags
  printf "\nTask 3 DONE! Check your progress! \n"
fi
