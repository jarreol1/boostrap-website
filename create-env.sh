#!/bin/bash

aws ec2 run-instances --image-id $1 --key-name hw3 --security-group-ids sg-e6f4219f --instance-type t2.micro --user-data file://installapp.sh --count 3

echo

echo “Sleeping for 30 seconds while instances are being run”

sleep 30

ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text`

aws elb create-load-balancer --load-balancer-name itmo-444-jaa --listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 --subnets subnet-ad4077c8

aws elb register-instances-with-load-balancer --load-balancer-name itmo-444-jaa --instances $ID

aws autoscaling create-launch-configuration --launch-configuration-name webserver --image-id ami-06b94666 --key-name hw3 --instance-type t2.micro --user-data file://installapp.sh

aws autoscaling create-auto-scaling-group --auto-scaling-group-name webserverdemo --launch-configuration webserver --availability-zone us-west-2b --load-balancer-name itmo-444-jaa --max-size 5 --min-size 0 --desired-capacity 1



