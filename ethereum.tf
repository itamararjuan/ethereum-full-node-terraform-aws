locals {
  ethereum_user_data = <<TFEOF
#! /bin/bash

apt-get update && apt-get install -y supervisor curl

mkdir -p /home/root/.local
BLOCK_STORAGE_NAME=$(lsblk | grep 4.9T | awk '{print $1}')
mkfs -t xfs /dev/$BLOCK_STORAGE_NAME
echo "/dev/$BLOCK_STORAGE_NAME /home/root/.local xfs defaults,nofail 0 0" >> /etc/fstab
mount -a

curl -O https://releases.parity.io/ethereum/v2.3.5/x86_64-unknown-linux-gnu/parity
chmod u+x parity

echo "[program:ethereum] 
command=/home/ubuntu/parity --tracing=on --pruning=archive
autostart=true
autorestart=true
stderr_logfile=/var/log/ethereum.err.log
stdout_logfile=/var/log/ethereum.out.log" >> /etc/supervisor/conf.d/ethereum.conf

supervisorctl reread && supervisorctl update

TFEOF
}

resource "aws_subnet" "ethereum" {
  count                   = 1
  vpc_id                  = "${module.vpc.id}"
  cidr_block              = "172.31.100.0/24"
  availability_zone       = "${aws_ebs_volume.ethereum_block_storage.availability_zone}"
  map_public_ip_on_launch = true

  tags = {
    Name = "ethereum-subnet"
  }
}

resource "aws_instance" "ethereum" {
  ami               = "${data.aws_ami.ubuntu-18_04.id}"
  count             = 1
  availability_zone = "${aws_ebs_volume.ethereum_block_storage.availability_zone}"
  instance_type     = "m5d.xlarge"
  security_groups   = ["${aws_security_group.ethereum.id}"]
  key_name          = "${aws_key_pair.deployer.key_name}"
  subnet_id         = "${ aws_subnet.ethereum.id }"
  private_ip        = "172.31.100.100"

  user_data = "${local.ethereum_user_data}"

  tags = {
    Name = "ethereum-full-node"
  }
}
