#! /bin/bash
$BUCKET_NAME=anhzf-gsp301
$VM_NAME=myvm
$STARTUP_SCRIPT=install-web.sh

gsutil mb gs://$BUCKET_NAME
gsutil cp install-web.sh gs://$BUCKET_NAME/$STARTUP_SCRIPT
gcloud compute instances create $VM_NAME \
  --zone=us-central1-a \
  --machine-type=f1-micro \
  --metadata=startup-script-url=gs://$BUCKET_NAME/install-web.sh \
  --tags=web
gcloud compute firewall-rules create default-allow-web \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=web