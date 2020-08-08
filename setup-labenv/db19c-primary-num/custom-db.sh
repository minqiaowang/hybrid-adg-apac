#cloud-config
runcmd:
   - yum -y install firewalld
   - firewall-offline-cmd --add-port=1521/tcp
   - systemctl stop firewalld
   - systemctl start firewalld
   - echo "AllowUsers opc oracle" >> /etc/ssh/sshd_config
   - systemctl restart sshd.service
   - mount /u01
   - /u01/ocidb/GenerateNetconfig.sh > /u01/ocidb/netconfig.ini
   - SIDNAME=ORCL DBNAME=ORCL DBCA_PLUGGABLE_DB_NAME=orclpdb /u01/ocidb/buildsingle.sh -s
