#!/bin/bash

CLUSTER_NAME=fancy-prod-234
ORDERS_ID=fancy-orders-757
PRODUCTS_ID=fancy-products-758
FRONTENT_ID=fancy-frontend-453
ROOT_DIR=~/monolith-to-microservices

printf "Building ${ORDERS_ID}...\n"
cd ${ROOT_DIR}/microservices/src/orders
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/${ORDERS_ID}:1.0.0 .
printf "Completed building ${ORDERS_ID}!\n\n"

printf "Building ${PRODUCTS_ID}...\n"
cd ${ROOT_DIR}/microservices/src/products
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/${PRODUCTS_ID}:1.0.0 .
printf "Completed building ${PRODUCTS_ID}!\n\n"

printf "Deploying ${ORDERS_ID}...\n"
kubectl create deployment $ORDERS_ID --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/${ORDERS_ID}:1.0.0
kubectl expose deployment $ORDERS_ID --type=LoadBalancer --port 80 --target-port 8081
printf "Completed deploying ${ORDERS_ID}!\n\n"

printf "Deploying ${PRODUCTS_ID}...\n"
kubectl create deployment $PRODUCTS_ID --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/${PRODUCTS_ID}:1.0.0
kubectl expose deployment $PRODUCTS_ID --type=LoadBalancer --port 80 --target-port 8082
printf "Completed deploying ${PRODUCTS_ID}!\n\n"
