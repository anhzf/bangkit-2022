#! /bin/bash

# PLEASE CONFIGURE THE VARS USING ./setup.sh FIRST!
# RUN THIS AFTER ./step1.sh

# create startup file for instance template later
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

# create a site via nginx web server using managed instance group with maximum 2 instances and using startup script above
# Create an instance template.
printf "\nCreating nginx template...\n"
gcloud compute instance-templates create nginx \
  --machine-type $SMALL_VM_TYPES \
  --metadata-from-file startup-script=startup.sh \
  --tags http-server \

# Create a target pool.
printf "\nCreating target pool...\n"
gcloud compute target-pools create nginx-pool \
  --region us-east1

printf "\nCreating managed instance group...\n"
gcloud compute instance-groups managed create nginx-site \
  --size 2 \
  --template nginx \
  --target-pool nginx-pool

# Create a firewall rule named as Firewall rule to allow traffic (80/tcp).
printf "\nCreating firewall rule...\n"
gcloud compute firewall-rules create $FIREWALL_NAME \
  --allow tcp:80 \
  --target-tags http-server

# Create a health check.
printf "\nCreating health check...\n"
gcloud compute http-health-checks create http

# Create a backend service, and attach the managed instance group with named port (http:80).
printf "\nCreating backend service...\n"
gcloud compute backend-services create nginx-service \
  --protocol HTTP \
  --http-health-checks http \
  --global

gcloud compute instance-groups managed set-named-ports nginx-site \
  --named-ports http:80

gcloud compute backend-services add-backend nginx-service \
  --instance-group nginx-site \
  --instance-group-zone us-east1-b \
  --global

# Create a URL map, and target the HTTP proxy to route requests to your URL map.
printf "\nCreating url map...\n"
gcloud compute url-maps create nginx-map \
  --default-service nginx-service \
  --global

gcloud compute target-http-proxies create nginx-proxy \
  --url-map nginx-map \
  --global

# Create a forwarding rule.
printf "\nCreating forwarding rule...\n"
gcloud compute forwarding-rules create nginx-lb \
  --ports=80 \
  --target-http-proxy nginx-proxy \
  --global

printf "\nAll steps completed!\n Try to access your web server!\n"