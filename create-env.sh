#!/bin/bash

if [ "$#" -ne 5 ]
then
    exit 1 	
else

aws ec2 run-instances --image-id $1 --key-name $2 --security-group-ids $3 --instance-type t2.micro --client-token current-running-instances --user-data file://installapp.sh --count 5

echo

echo “Sleeping for 30 seconds while instances are being run”

sleep 30

ID=`aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,ClientToken]' | grep current-running-instances | awk '{print $1}'`

aws elb create-load-balancer --load-balancer-name itmo-444-jaa --listeners Protocol=Http,LoadBalancerPort=80,InstanceProtocol=Http,InstancePort=80 --subnets subnet-ad4077c8

aws elb register-instances-with-load-balancer --load-balancer-name itmo-444-jaa --instances $ID

aws autoscaling create-launch-configuration --launch-configuration-name $4 --image-id $1 --key-name hw4 --instance-type t2.micro --user-data file://installapp.sh

aws autoscaling create-auto-scaling-group --auto-scaling-group-name webserverdemo --launch-configuration $4 --availability-zone us-west-2b --load-balancer-name itmo-444-jaa --max-size 5 --min-size 0 --desired-capacity 1

fi
