#! /bin/bash

# GSP322 Challenge  | https://www.cloudskillsboost.google/focuses/12068

NETWORK=acme-vpc
SUBNET1_VMs=bastion
SUBNET2_VMs=juice-shop

read -p "Enter Zone: " zone
gcloud config set compute/zone $zone

printf "\n-------------------------------------------------------\n"
printf "Task 1: Remove the overly permissive rules.\n"
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  gcloud compute firewall-rules list
  while : ; do
    read -p "According to the list, which firewall-rules name to deletes? (space separated): " fw_names
    printf "You're about to deletes the following firewall-rules: \n $fw_names.\n"
    read -p "Continue? [y/n]: " want_to_continue

    if [ "$want_to_continue" == "y" ]; then
      gcloud compute firewall-rules delete $fw_names
      break
    fi
  done

  printf "\nTask 1 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 2: Start the bastion host instance.\n"
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  gcloud compute instances list
  while : ; do
    read -p "According to the list, which instance name to start? (space separated): " instance_names
    printf "You're about to start the following instance: \n $instance_names.\n"
    read -p "Continue? [y/n]: " want_to_continue

    if [ "$want_to_continue" == "y" ]; then
      gcloud compute instances start $instance_names
      break
    fi
  done

  printf "\nTask 2 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 3: Create a firewall rule that allows SSH (tcp/22) from the IAP service and add network tag on bastion.\n"
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  read -p "Enter the SSH IAP network tag name: " tag_name
  gcloud compute instances add-tags $SUBNET1_VMs \
    --tags $tag_name
  gcloud compute firewall-rules create allow-ssh-ingress-from-iap \
    --direction INGRESS \
    --action allow \
    --rules tcp:22 \
    --source-ranges 35.235.240.0/20 \
    --target-tags $tag_name \
    --network $NETWORK

  printf "\nTask 3 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 4: Create a firewall rule that allows traffic on HTTP (tcp/80) to any address and add network tag on juice-shop.\n"
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  read -p "Enter the HTTP network tag name: " tag_name
  gcloud compute instances add-tags $SUBNET2_VMs \
    --tags $tag_name
  gcloud compute firewall-rules create allow-frontend-http \
    --direction INGRESS \
    --action allow \
    --rules tcp:80 \
    --target-tags $tag_name \
    --network $NETWORK

  printf "\nTask 4 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 5: Create a firewall rule that allows traffic on SSH (tcp/22) from acme-mgmt-subnet.\n"
# You need to connect to juice-shop from the bastion using SSH.
# Create a firewall rule that allows traffic on SSH (tcp/22) from acme-mgmt-subnet network address.
# The firewall rule must be enabled for the juice-shop instance using a network tag of <SSH internal network tag>.
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  gcloud compute networks subnets list
  read -p "According to the list, Enter ip range for subnet named 'acme-mgmt-subnet': " ip_ranges
  read -p "Enter SSH internal network tag name: " tag_name
  read -p "Enter instance name to add tag (space separated): " instance_names
  gcloud compute instances add-tags $SUBNET2_VMs \
    --tags $tag_name
  gcloud compute firewall-rules create allow-ssh-ingress-from-acme-mgmt-subnet \
    --direction INGRESS \
    --action allow \
    --rules tcp:22 \
    --target-tags $tag_name \
    --source-ranges $ip_ranges \
    --network $NETWORK

  printf "\nTask 5 DONE! Check your progress! \n"
fi

printf "\n-------------------------------------------------------\n"
printf "Task 6: SSH to bastion host via IAP and juice-shop via bastion.\n"
printf "In this task you just SSH bastion then SSH juice-shop.\n"
printf "Congratulations! You've completed the challenge!\n"
