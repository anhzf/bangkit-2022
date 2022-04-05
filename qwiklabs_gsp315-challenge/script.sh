if [ -z $DEVSHELL_PROJECT_ID ]; then
  read -p "Enter Project ID: " project_id
else
  printf "Detected project id using: ${DEVSHELL_PROJECT_ID}\n"
  read -p "Enter Project ID [Press enter to skip]: " project_id
  project_id=${project_id:-DEVSHELL_PROJECT_ID}
fi

printf "\nTask 1: Create a Bucket\n"
read -p "Enter Bucket Name: " bucket_name
gsutil mb gs://$bucket_name

printf "\nTask 1 DONE! Check your progress! \n"

printf "\nTask 2: Create a Pub/Sub topic\n"
read -p "Enter Topic Name: " topic_name
gcloud pubsub topics create $topic_name

printf "\nTask 2 DONE! Check your progress! \n"

printf "\nTask 3: Create the thumbnail Cloud Function\n"
mkdir thumbnail-functions
cat << EOF > thumbnail-functions/index.js
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");
exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "${topic_name}";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(\`Processing Original: gs://\${bucketName}/\${fileName}\`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(\`Error: \${err}\`);
            reject(err);
          })
          .on("finish", () => {
            console.log(\`Success: \${fileName} → \${newFilename}\`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(\`Message \${messageId} published.\`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(\`gs://\${bucketName}/\${fileName} is not an image I can handle\`);
    }
  }
  else {
    console.log(\`gs://\${bucketName}/\${fileName} already has a thumbnail\`);
  }
};
EOF
cat << EOF > thumbnail-functions/package.json
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
EOF
read -p "Enter Function Name: " function_name
read -p "Enter Region: " region
gcloud functions deploy $function_name \
  --runtime=nodejs16 \
  --trigger-bucket=gs://$bucket_name \
  --source=./thumbnail-functions \
  --entry-point=thumbnail \
  --region=$region

printf "Testing the function triggered by topic...\n"
gsutil cp gs://cloud-training/gsp315/map.jpg gs://$bucket_name/test.png

printf "\nTask 3 DONE! Check your progress! \n"

printf "\nTask 4: Remove the previous cloud engineer"
read -p "Enter Cloud Engineer Username: " cloud_engineer_username
gcloud projects remove-iam-policy-binding $project_id \
  --member="user:$cloud_engineer_username" \
  --role="roles/viewer"

printf "\nTask 4 DONE! Check your progress! \n"