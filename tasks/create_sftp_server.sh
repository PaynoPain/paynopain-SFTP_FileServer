#!/bin/bash

INSTANCE_ID=$(aws ec2 run-instances --image-id ami-00035f41c82244dab --count 1 --instance-type t2.nano --key-name Sistemas_Ireland --security-group-ids sg-0c92d7e445265d896 --subnet-id subnet-38d7675d | grep InstanceId | awk '{$1=$1};1' | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')

aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=SFTP_upload

ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc | grep AllocationId | awk '{$1=$1};1' | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')

aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID

PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | grep PrivateIpAddress | awk '{$1=$1};1' | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')

ssh -i /root/.ssh/Sistemas_Ireland.pem ubuntu@$PRIVATE_IP sudo echo "
Match User pnpfiles
  PasswordAuthentication yes
  ForceCommand internal-sftp
  PermitTunnel no
  AllowAgentForwarding no
  AllowTcpForwarding no
  X11Forwarding no
" >> /etc/ssh/sshd_config

ssh -i /root/.ssh/Sistemas_Ireland.pem ubuntu@$PRIVATE_IP sudo /etc/init.d/sshd restart

exit 0
