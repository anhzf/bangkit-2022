#! /bin/dev

# GSP314  | https://www.cloudskillsboost.google/focuses/10417
# Use this for jumphost-instance via SSH

INSTANCE_TYPE=n1-standard-1

read -p "Enter Project ID: " project_id
read -p "Enter Region: " region
read -p "Enter Zone: " zone

NETWORK_CONFIG_PATH=/work/dm/prod-network.yaml
sed -i s/SET_REGION/$region/g $NETWORK_CONFIG_PATH

gcloud deployment-manager deployments create adv-cfg \
  --config $NETWORK_CONFIG_PATH

NETWORK_NAME=kraken-prod-vpc
SUBNETWORK_NAME=kraken-prod-subnet
read -p "Enter Cluster Name: " cluster_name
gcloud container clusters create $cluster_name \
  --zone $zone \
  --num-nodes 2 \
  --machine-type $INSTANCE_TYPE \
  --network $NETWORK_NAME \
  --subnetwork $SUBNETWORK_NAME

gcloud container clusters get-credentials $cluster_name \
  --zone $zone

kubectl apply -f /work/k8s/
