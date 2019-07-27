mkfs -t ext4 /dev/xvdf
mkdir /opt/data
mount /dev/xvdf /opt/data
echo /dev/xvdf  /opt/data ext4 defaults,nofail 0 2 >> /etc/fstab