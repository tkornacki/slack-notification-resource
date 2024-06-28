#!/bin/bash
set -e

BASE_DIR=$(pwd | grep -o ".*rapidsos")

# Append /repos/ to the base directory
BASE_DIR=$(echo "$BASE_DIR/repos/milky-way/")

# Check if the base directory is found
if [[ -z "$BASE_DIR" ]]; then
  echo "Error: /repos/ directory not found"
  exit 1
fi

DOCKER_TAG="v0.1.0"
DOCKER_IMAGE_NAME="concourse-ci/slack-notification-resource"

# Build the dockerfile
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_TAG -f ./Dockerfile .

AWS_REPO=467536752717.dkr.ecr.us-east-1.amazonaws.com/concourse-ci/slack-notification-resource

# Tag the dockerfile
docker tag $DOCKER_IMAGE_NAME:$DOCKER_TAG $AWS_REPO:$DOCKER_TAG
echo "Tagged the docker image as $AWS_REPO:$DOCKER_TAG"
echo "Pushing to ECR"

# Login to awsume
aws-sso-util login

# Push
AWS_PROFILE_CMD='AWS_PROFILE=Rapidsos-mgmt.Admin'
eval $AWS_PROFILE_CMD docker push $AWS_REPO:$DOCKER_TAG

# Define the environment
ENV="dev"

# Define the pipeline file and name
PIPELINE_FILE="$BASE_DIR/utils/concourse-ci/tests/same-day-deployment/pipeline.yaml"
PIPELINE_NAME="slack-test"

# Define the job name
JOB_NAME="slack-test"

# Execute the deploy script
$BASE_DIR/utils/concourse-ci/scripts/deploy-pipeline/deploy.sh -e $ENV -f $PIPELINE_FILE -n $PIPELINE_NAME -j $JOB_NAME
