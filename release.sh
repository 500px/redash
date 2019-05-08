#!/bin/bash
set -e

tag=$1
service=redash
ecr_uri="669607800383.dkr.ecr.us-east-1.amazonaws.com/$service"

echo "Logging into Docker Hub"
docker login --username "$DOCKER_HUB_USER" --password "$DOCKER_HUB_PASSWORD"

echo "Logging into ECR"
eval $(aws ecr get-login --no-include-email --region us-east-1)

# Build
docker build -t "$service" --build-arg GITHUB_TOKEN="$GITHUB_TOKEN" .

# Tag
docker tag $service:latest ${ecr_uri}:latest
docker tag $service:latest ${ecr_uri}:$tag

# Push
docker push ${ecr_uri}:latest
docker push ${ecr_uri}:$tag
