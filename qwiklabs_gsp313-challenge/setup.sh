#! /bin/bash

setEnvVar() {
  local varName=$1
  
  if [ -z $varName ]; then
    echo "Please set $varName"
    exit 1
  fi

  if [ -z $2 ]; then
    read -p "Enter your $varName: " varValue
  else
    read -p "Enter your $varName [$2]: " varValue
  fi

  export $varName=${varValue:-$2}
  printenv $varName
}

setEnvVar "PROJECT_ID" $DEVSHELL_PROJECT_ID
setEnvVar "COMPUTE_ZONE" "us-east1-b"
setEnvVar "INSTANCE_NAME"
setEnvVar "APP_PORT"
setEnvVar "FIREWALL_NAME"
setEnvVar "SMALL_VM_TYPES" "f1-micro"
setEnvVar "WINDOWS_VM_TYPES" "n1-standard-1"