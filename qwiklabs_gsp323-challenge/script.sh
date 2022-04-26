#! /bin/dev

# GSP323  | https://www.cloudskillsboost.google/focuses/11044

if [ -z $DEVSHELL_PROJECT_ID ]; then
  read -p "Enter Project ID: " project_id
else
  printf "Detected project id using: ${DEVSHELL_PROJECT_ID}\n"
  read -p "Enter Project ID [Press enter to skip]: " project_id
  project_id=${project_id:-DEVSHELL_PROJECT_ID}
fi

printf '\n-------------------------------------------------------\n'
printf 'Task 1: Run a simple Dataflow job\n'
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  read -p 'Enter BigQuery Dataset Name: ' dataset_name
  read -p 'Enter Cloud Storage Bucket Name: ' bucket_name
  read -p 'Enter Output Table Name: '  output_table_name
  read -p 'Enter Temporary BigQuery Directory: '  temp_bq_dir
  read -p 'Enter Temporary Location': temp_location
  gsutil mb gs://$bucket_name

  TABLE_NAME=customers
  bq mk $dataset_name
  bq mk \
    --table \
    $project_id:$dataset_name.$TABLE_NAME \
    gs://cloud-training/gsp323/lab.schema
  bq load \
    --source_format=CSV \
    $project_id:$dataset_name.$TABLE_NAME \
    gs://cloud-training/gsp323/lab.csv

  printf "\nATTENTION ⚠️\n"
  printf "You need to submit a job in Dataflow.\n
  In Navigation Menu goto Jobs in Dataflow submenu then Create Job From Template.\n
  Below is some field you need to note:\n
  Select 'Text files on Cloud Storage to BigQuery' in 'Dataflow template' field.\n
  The rest field you can do it self!\n"
gcloud dataflow jobs run job-customer-2 --gcs-location gs://dataflow-templates-us-central1/latest/GCS_Text_to_BigQuery --region us-central1 --staging-location gs://6a770e58-87a0-4433-a4d3-fcc6ec5753f3/temp --parameters javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,JSONPath=gs://cloud-training/gsp323/lab.schema,javascriptTextTransformFunctionName=transform,outputTable=qwiklabs-gcp-03-ddd07356e1a6:lab_193.customers_713,inputFilePattern=gs://cloud-training/gsp323/lab.csv,bigQueryLoadingTemporaryDirectory=gs://6a770e58-87a0-4433-a4d3-fcc6ec5753f3/bigquery_temp
  can_continue=true
  while can_continue; do
    read -p "Did you submit a Dataflow Job? (type 'YES' to continue)\n" did_it
    if [ "$did_it" == "YES" ]; then
      can_continue=false
    else
      printf "Please submit a Dataflow Job and try again.\n"
    fi
  done
  printf "\nTask 1 DONE! Check your progress!\n"\
fi

printf "\n-------------------------------------------------------\n"
printf "Task 2: Run a simple Dataproc job\n"
# You have used Dataproc in the quest, now you must run another example Spark job using Dataproc.
# Before you run the job, log into one of the cluster nodes and copy the /data.txt file
# into hdfs (use the command hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt).
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  read -p "Enter Dataproc Cluster Name: " cluster_name
  read -p "Enter Region: " region
  gcloud dataproc clusters create $cluster_name --region $region

  printf "\nATTENTION ⚠️\n"
  printf "Please goto Dataproc -> Clusters -> Select your created cluster -> VM Instances -> SSH\n
  Then run the following command:\n
  hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.txt\n"

  can_continue=true
  while can_continue; do
    read -p "Have done following the above instructions? (type 'YES' to continue)\n" did_it
    if [ "$did_it" == "YES" ]; then
      can_continue=false
    else
      printf "Please follow the above instructions.\n"
    fi
  done

  printf "\nSubmitting a Spark job to Dataproc...\n"
  read -p "Enter Region: " region
  gcloud dataproc jobs submit spark \
    --cluster $cluster_name \
    --region $region \
    --class org.apache.spark.examples.SparkPageRank \
    --jars file:///usr/lib/spark/examples/jars/spark-examples.jar \
    --max-failures-per-hour 1 \
    -- \
    /data.txt
  printf "\nTask 2 DONE! Check your progress!\n"
fi

printf '\n-------------------------------------------------------\n'
printf 'Task 3: Run a simple Spark job\n'
printf "Dataprep by Trifacta doesn\'t provide the CLI. Do it yourself!\n
Good luck!\n"

can_continue=true
while can_continue; do
  read -p "Have done? (type 'YES' to continue)\n" did_it
  if [ "$did_it" == "YES" ]; then
    can_continue=false
  else
    printf "Please done the step first!\n"
  fi
done
printf "\nCongrats, Task 3 DONE! Check your progress!\n"

printf '\n-------------------------------------------------------\n'
printf 'Task 4: Run a simple Dataprep job\n'
read -p "Continue? [y/n]: " want_to_continue
if [ "$want_to_continue" == "y" ]; then
  printf "\nAnalyzing with Natural Language Processing...\n"
  gcloud iam service-accounts create my-natlang-sa \
    --display-name "my natural language service account"
  gcloud iam service-accounts keys create ~/key.json \
    --iam-account my-natlang-sa@${project_id}.iam.gserviceaccount.com
  GOOGLE_APPLICATION_CREDENTIALS="/home/$USER/key.json"
  gcloud auth activate-service-account my-natlang-sa@${project_id}.iam.gserviceaccount.com \
    --key-file=$GOOGLE_APPLICATION_CREDENTIALS
  gcloud ml language analyze-entities \
    --content="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat." > result.json
  gcloud auth login 
  read -p "Enter Upload Location for Cloud Natural Language result: " upload_location
  gsutil cp result.json $upload_location
  
  printf "\nAnalyzing with Cloud Speech API...\n"
  printf "Please create an API KEY, then copy the key here:\n"
  read -p "Enter the API KEY: " api_key
  cat << EOF > request.json
{
  "config": {
    "encoding":"FLAC",
    "languageCode": "en-US"
  },
  "audio": {
    "uri":"gs://cloud-training/gsp323/task4.flac"
  }
}
EOF
  curl -s -X POST -H "Content-Type: application/json" \
    --data-binary @request.json \
    "https://speech.googleapis.com/v1/speech:recognize?key=${api_key}" > result.json
  read -p "Enter Upload Location for Cloud Speech result: " upload_location
  gsutil cp result.json $upload_location
  
  printf "\nAnalyzing with Google Video Intelligence Processing...\n"
  gcloud iam service-accounts create quickstart
  gcloud iam service-accounts keys create key.json \
    --iam-account quickstart@${project_id}.iam.gserviceaccount.com
  gcloud auth activate-service-account \
    --key-file key.json
  ACCESS_TOKEN=$(gcloud auth print-access-token)
  cat << EOF > request.json
{
  "inputUri":"gs://spls/gsp154/video/train.mp4",
  "features": [
    "TEXT_DETECTION"
  ]
}
EOF
  curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json
  curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    'https://videointelligence.googleapis.com/v1/operations/OPERATION_FROM_PREVIOUS_REQUEST' > result1.json
  gsutil cp result1.json gs://$project_id-marking/task4-gvi.result

  printf "Task 4 DONE! Check your progress!\n"
fi
