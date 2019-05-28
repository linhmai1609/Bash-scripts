#!/bin/bash
ssh -l mlbl 192.168.100.165 /bin/bash < ins_basic_soft_centos.sh

sudo yum -y update
sudo yum -y install nano

exit
