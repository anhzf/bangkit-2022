#! /bin/dev

# GSP318  | https://www.cloudskillsboost.google/focuses/10457

RESOURCE_PREFIX=kraken_
REGION=us-east1
ZONE=us-east1-b
MACHINE_TYPE=n1-standard-1
APP_NAME=valkyrie-app

source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)

gcloud source repos clone $APP_NAME

WORKDIR=~/$APP_NAME

cd WORKDIR

cat << EOF > Dockerfile
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

IMAGE_NAME=<REPLACE-THIS>
TAG_NAME=<REPLACE-THIS>
docker image build -t $IMAGE_NAME:$TAG_NAME .
~/marking/step1_v2.sh

docker run -d -p 8080:8080 $IMAGE_NAME:$TAG_NAME
~/marking/step2_v2.sh

PROJECT_ID=$DEVSHELL_PROJECT_ID
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG_NAME

CLUSTER_NAME=valkyrie-dev
gcloud container clusters get-credentials $CLUSTER_NAME

# REPLACE VALUES ON k8s yaml files
kubectl apply -f $WORKDIR/k8s/deployment.yaml
kubectl apply -f $WORKDIR/k8s/service.yaml

REPLICAS=<REPLACE-THIS>
kubectl scale deployment $APP_NAME --replicas=$REPLICAS

git checkout master
git merge origin/kurt-dev

TAG_NAME=<REPLACE-THIS>
docker image build -t $IMAGE_NAME:$TAG_NAME .
docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$TAG_NAME

# UPDATE IMAGE VERSION
kubectl edit deployment $APP_NAME

printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &

# SETUP JENKINS

sed -i s/YOUR_PROJECT/$PROJECT_ID/g $WORKDIR/Jenkinsfile
sed -i s/green/orange/g $WORKDIR/source/html.go

git commit -ma "Update Jenkinsfile and html.go"
git push origin master

