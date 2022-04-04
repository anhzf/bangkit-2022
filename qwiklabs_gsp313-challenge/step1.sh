#! /bin/bash

# PLEASE CONFIGURE THE VARS USING ./setup.sh FIRST!

# script start here
printf "\nSetting up...\n"
gcloud config set compute/zone $COMPUTE_ZONE

# create instance named $INSTANCE_NAME with $SMALL_VM_TYPES using debian linux image
printf "\nCreating ${INSTANCE_NAME} instance...\n"
gcloud compute instances create $INSTANCE_NAME \
  --machine-type $SMALL_VM_TYPES \

# create kubernetes cluster with us-east1-b zone
printf "\nCreating kubernetes cluster...\n"
gcloud container clusters create nucleus-webserver1
# set kubectl context to the cluster
gcloud container clusters get-credentials nucleus-webserver1

# deploy a container in cluster using gcr.io/google-samples/hello-app:2.0 image then expose to $APP_PORT
printf "\nCreating & Deploying hello-app...\n"
kubectl create deployment hello-app \
  --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-app \
  --port $APP_PORT \
  --type LoadBalancer

printf "\nStep 1 DONE! Please waiting for the hello-app external IP ready.
Check it by using command `kubectl get services`
when external IP are available then run ./step2.sh to continue.\n"