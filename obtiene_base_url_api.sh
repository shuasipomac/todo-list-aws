#!/bin/bash

#check script input parameters
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <stage> <region>"
  exit 1
fi

#asign input parameters to local variables
stage=$1
region=$2

#check that Stage is not missing or empty
if [ -z "$stage" ]; then
    echo "Error: Stage is missing or empty."
    exit 1
fi

#check that Region is not missing or empty
if [ -z "$region" ]; then
    echo "Error: Region is missing or empty."
    exit 1
fi

#echo of the input variables
echo "obtiene_base_url_api.sh --> Input 1 'stage' value: $stage"
echo "obtiene_base_url_api.sh --> Input 2 'region' value: $region"

#execute aws cloudformation describe stack command for getting the outputs of sam deploy command base on Stage value
if [ "$stage" == "default" ]; then
    outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws --region $region | jq '.Stacks[0].Outputs')
        
else    
    //outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-$stage --region $region | jq '.Stacks[0].Outputs')
      outputs=$(aws cloudformation describe-stacks --stack-name $stage-todo-list-aws --region $region | jq '.Stacks[0].Outputs')
fi

#function for extracting using jq the base url value
extract_value() {
    echo "$1" | jq -r ".[] | select(.OutputKey==\"$2\") | .OutputValue"
}

#extract base url value
BASE_URL_API=$(extract_value "$outputs" "BaseUrlApi")

#save base url value to a temporal file
echo $BASE_URL_API > base_url_api.tmp





// if [ "$#" -lt 2 ]; then
//  echo "Usage: $0 <stage> <region>"
//  exit 1
// fi

// stage=$1
// region=$2

// echo "obtiene_base_url_api.sh --> Input 1 'stage' value: $stage"
// echo "obtiene_base_url_api.sh --> Input 2 'region' value: $region"


// outputs=$(aws cloudformation describe-stacks --stack-name $stage-todo-list-aws --region $region | jq '.Stacks[0].Outputs')

// extract_value() {
//    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
// }

// BASE_URL_API=$(extract_value "BaseUrlApi")

// echo $BASE_URL_API > base_url_api.tmp
