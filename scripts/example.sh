#!/bin/bash
# Create Physical Volumes
# Assume that you have a /dev/xvdc as data disk
# Using pvcreate to create a logical volume based on data disk
pvcreate /dev/xvdc

# Create Volume Groups
# Using vgcreate to create a volume group
vgcreate icp-vg /dev/xvdc

# Create Logical Volumes
# ${kubelet_lv} ${etcd_lv} ${docker_lv} ${management_lv} are the disk size
lvcreate -L ${kubelet_lv}G -n kubelet-lv icp-vg 
lvcreate -L ${etcd_lv}G -n etcd-lv icp-vg
#lvcreate -L ${registry_lv}G -n registry-lv icp-vg
lvcreate -L ${docker_lv}G -n docker-lv icp-vg
lvcreate -L ${management_lv}G -n management-lv icp-vg

#Create Filesystems
# Format the logical volumes as ext4 
mkfs.ext4 /dev/icp-vg/kubelet-lv
mkfs.ext4 /dev/icp-vg/docker-lv
mkfs.ext4 /dev/icp-vg/etcd-lv
#mkfs.ext4 /dev/icp-vg/registry-lv
mkfs.ext4 /dev/icp-vg/management-lv

# Create Directories
mkdir -p /var/lib/docker
mkdir -p /var/lib/kubelet
mkdir -p /var/lib/etcd
mkdir -p /var/lib/registry
mkdir -p /var/lib/icp

# Add mount in /etc/fstab
# Finally we link the folder with the logical volume 
# put it into /etc/fstab to persist the volume during restart
cat <<EOL | tee -a /etc/fstab
/dev/mapper/icp--vg-kubelet--lv /var/lib/kubelet ext4 defaults 0 0
/dev/mapper/icp--vg-docker--lv /var/lib/docker ext4 defaults 0 0
/dev/mapper/icp--vg-etcd--lv /var/lib/etcd ext4 defaults 0 0
/dev/mapper/icp--vg-management--lv /var/lib/icp ext4 defaults 0 0
EOL

# Mount Registry for Single Master
# if condition, optional
if [ ${flag_ma_nfs} -eq 0 ]; then
  lvcreate -L ${registry_lv}G -n registry-lv icp-vg
  mkfs.ext4 /dev/icp-vg/registry-lv
  cat <<EOR | tee -a /etc/fstab
/dev/mapper/icp--vg-registry--lv /var/lib/registry ext4 defaults 0 0
EOR

fi

# Mount Filesystems
# Using mount command to mount all
# If mount success, will have no error or log output.
mount -a

# How to verfiy?
# Using df -Th <the directory you create>
# The output should return you the example name as : /dev/mapper/icp--<logical volume you create just now>--lv