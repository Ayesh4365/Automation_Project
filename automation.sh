#!/bin/bash
s3bucket="upgrad-ayesh"
name="ayesh"
apt update -y
read REQUIRED_PKG
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi
systemctl is-active --quiet apache2 || systemctl start apache2
systemctl is-enabled --quiet apache2 || systemctl enable apache2
timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log
if [ -f /tmp/${name}-httpd-logs-${timestamp}.tar ];
then
    aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3bucket}/${name}-httpd-logs-${timestamp}.tar
fi
