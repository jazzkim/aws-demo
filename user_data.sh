#!/bin/bash

sudo yum install httpd -y 


mkfs.xfs /dev/xvdh  
mkdir -p /web 

cat << EOF >> /etc/fstab
/dev/xvdh   /web          xfs   defaults     0 0
EOF

sudo mount  -av 

echo "<p> Hello GR World </p>" >> /var/www/html/index.html

sudo systemctl enable httpd
sudo systemctl start httpd