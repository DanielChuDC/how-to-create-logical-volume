#!/bin/bash
# Create Physical Volumes
# Assume that you have a /dev/xvdc as data disk
# Using pvcreate to create a logical volume based on data disk
# Check existing pv by issue pvscan or pvdisplay
# In this case I reuse the pv that I had created
# pvcreate /dev/xvdc

# Create Volume Groups
# Using vgcreate to create a volume group
# Check existing vg by issue vgscan or vgdisplay
# In this case I reuse the vg that I had created
# vgcreate icp-vg /dev/xvdc

# Create Logical Volumes
# Use 10GB as disk size

# /k8s/data/cassandra - Cassandra persistent storage 
lvcreate -L 10G -n cassandra-lv icp-vg 
# /k8s/data/zookeeper - Zookeeper persistent storage
lvcreate -L 10G -n zookeeper-lv icp-vg 
# /k8s/data/kafka - Kafka persistent storage
lvcreate -L 10G -n kafka-lv icp-vg 
# /k8s/data/couchdb - CouchDB persistent storage
lvcreate -L 10G -n couchdb-lv icp-vg 
# /k8s/data/datalayer - Datastore persistent storage
lvcreate -L 10G -n datalayer-lv icp-vg 

#Create Filesystems
# Format the logical volumes as ext4 
mkfs.ext4 /dev/icp-vg/cassandra-lv
mkfs.ext4 /dev/icp-vg/zookeeper-lv
mkfs.ext4 /dev/icp-vg/kafka-lv
mkfs.ext4 /dev/icp-vg/couchdb-lv
mkfs.ext4 /dev/icp-vg/datalayer-lv


# Create Directories
mkdir -p /k8s/data/cassandraCopy
mkdir -p /k8s/data/zookeeperCopy
mkdir -p /k8s/data/kafkaCopy
mkdir -p /k8s/data/couchdbCopy
mkdir -p /k8s/data/datalayer

# Add mount in /etc/fstab
# Finally we link the folder with the logical volume 
# put it into /etc/fstab to persist the volume during restart
cat <<EOL | tee -a /etc/fstab
/dev/mapper/icp--vg-cassandra--lv /k8s/data/cassandraCopy ext4 defaults 0 0
/dev/mapper/icp--vg-zookeeper--lv /k8s/data/zookeeperCopy ext4 defaults 0 0
/dev/mapper/icp--vg-kafka--lv /k8s/data/kafkaCopy ext4 defaults 0 0
/dev/mapper/icp--vg-couchdb--lv /k8s/data/couchdbCopy ext4 defaults 0 0
/dev/mapper/icp--vg-datalayer--lv /k8s/data/datalayer ext4 defaults 0 0
EOL

# Mount Filesystems
# Using mount command to mount all
# If mount success, will have no error or log output.
mount -a

# How to verfiy?
# Using df -Th <the directory you create>
# The output should return you the example name as : /dev/mapper/icp--<logical volume you create just now>--lv