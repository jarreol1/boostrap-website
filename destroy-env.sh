#!/bin/bash

AS=`aws autoscaling describe-auto-scaling-groups | awk '{print $3}' | head -1`

ASLC=`aws autoscaling describe-auto-scaling-groups | awk '{print $9}' | head -1`

LB=`aws elb describe-load-balancers | awk '{print $6}' | head -1`

ILB=`aws elb describe-load-balancers | tail -n +3 | awk '{print $2}' | grep "i-*"`

ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text`

aws autoscaling detach-load-balancers --load-balancer-names $LB --auto-scaling-group-name $AS

aws elb deregister-instances-from-load-balancer --load-balancer-name $LB --instances $ILB

aws elb delete-load-balancer-listeners --load-balancer-name $LB --load-balancer-ports 80

aws elb delete-load-balancer --load-balancer-name $LB

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $AS --force-delete

aws autoscaling delete-launch-configuration --launch-configuration-name $ASLC

aws ec2 terminate-instances --instance-ids $ID
