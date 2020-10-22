#!/bin/bash

export PROJECT="creating-a-l-60-e30f45b1"
export ACCOUNT="167207709836-compute@developer.gserviceaccount.com"

gcloud compute instances stop web-1
gcloud compute instances stop web-2

gcloud compute images create web-v1 \
--family=webserver \
--source-disk=web-1 \
--source-disk-zone=us-central1-a

gcloud compute images create web-v2 \
--family=webserver \
--source-disk=web-2 \
--source-disk-zone=us-central1-a

gcloud beta compute instance-templates create instance-template-1 \
--machine-type=e2-micro \
--network=projects/$PROJECT/global/networks/default \
--network-tier=PREMIUM \
--maintenance-policy=MIGRATE \
--service-account=$ACCOUNT \
--image=web-v1 \
--image-project=$PROJECT \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=instance-template-1 \
--reservation-affinity=any \
--tags=http-server \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append 



gcloud compute  health-checks create tcp "healcth-check-1" \
--project $PROJECT \
--timeout "5" \
--check-interval "10" \
--unhealthy-threshold "3" \
--healthy-threshold "2" \
--port "80"


gcloud beta compute instance-groups managed create instance-group-1 \
--project=$PROJECT \
--base-instance-name=instance-group-1 \
--template=instance-template-1 \
--size=1 \
--zone=us-central1-a \
--health-check=healcth-check-1 \
--initial-delay=300

gcloud beta compute instance-groups managed set-autoscaling "instance-group-1" \
--project=$PROJECT \
--zone "us-central1-a" \
--cool-down-period "60" \
--max-num-replicas "3" \
--min-num-replicas "1" \
--target-cpu-utilization "0.6" \
--mode "on" 


