#!/bin/bash

IDENTIFIER="fancy-monolith-338"

printf "Enabling Cloud Build APIs...\n"
gcloud services enable cloudbuild.googleapis.com
printf "Completed.\n\n"

printf "Building Monolith Container...\n"
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/${IDENTIFIER}:1.0.0 .
printf "Completed.\n\n"

printf "Deploying Monolith To GKE Cluster...\n"
kubectl create deployment $IDENTIFIER --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/${IDENTIFIER}:1.0.0
kubectl expose deployment $IDENTIFIER --type=LoadBalancer --port 80 --target-port 8080
printf "Completed.\n\n"

printf "Please run the following command to find the IP address for the ${IDENTIFIER} service: kubectl get service ${IDENTIFIER}\n\n"

printf "Deployment completed successfully!\n"
