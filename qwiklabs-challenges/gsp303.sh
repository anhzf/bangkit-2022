#! /bin/bash
$VPC_NAME=securenetwork
$SUBNET_NAME=securenetwork

gcloud compute networks create $VPC_NAME \
  --subnet-mode=custom \
  --mtu=1460 \
  --bgp-routing-mode=regional
gcloud compute networks subnets create $SUBNET_NAME \
  --range=10.10.0.0/16 \
  --network=$VPC_NAME \
  --region=us-central1
gcloud compute firewall-rules create securenetwork-allow-rdp --direction=INGRESS --priority=1000 --network=securenetwork --action=ALLOW --rules=tcp:3389 --source-ranges=0.0.0.0/0 --target-tags=rdp-in-allow
gcloud compute instances create vm-bastionhost --project=qwiklabs-gcp-04-48bc307e7500 --zone=us-central1-a --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=securenetwork --network-interface=subnet=default,no-address --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --service-account=1057747690603-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=rdp-in-allow --create-disk=auto-delete=yes,boot=yes,device-name=vm-bastionhost,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220414,mode=rw,size=50,type=projects/qwiklabs-gcp-04-48bc307e7500/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute instances create vm-securehost --project=qwiklabs-gcp-04-48bc307e7500 --zone=us-central1-a --machine-type=e2-medium --network-interface=subnet=securenetwork,no-address --network-interface=subnet=default,no-address --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --service-account=1057747690603-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=vm-securehost,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220414,mode=rw,size=50,type=projects/qwiklabs-gcp-04-48bc307e7500/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute reset-windows-password vm-bastionhost --user app_admin --zone us-central1-a