#! /bin/dev

CLUSTER_NAME=echo-cluster
ZONE=us-central1-a
INSTANCE_TYPE=n1-standard-2

gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --num-nodes 2 \
  --machine-type $INSTANCE_TYPE


IMAGE_NAME=echo-app

gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/$IMAGE_NAME:v1


IMAGE_NAME=echo-app
DEPLOYMENT_NAME=echo-web

kubectl create deployment $DEPLOYMENT_NAME --image=gcr.io/$DEVSHELL_PROJECT_ID/$IMAGE_NAME:v1
kubectl expose deployment $DEPLOYMENT_NAME --type=LoadBalancer --port=80 --target-port=8000