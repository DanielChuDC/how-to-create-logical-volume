# how-to-create-logical-volume

This repo illustrate how to create logical volume and mount it into linux operating system

# Before you begin

### Prerequisites package to run the command in [script example](scripts/example.sh)

```s
#  Verify LVM is installed or not on the server.
rpm -qa |grep -i lvm


# Install the lvm2 package
yum install lvm2*

# Check the LVM version.
lvm version
```

<img src="imgs/example.png">

Navigate to [script example](scripts/example.sh) to know how to execute the command.

# How to verfiy?

1.

`df -Th <the directory you create>`
The output should return you the example name as : /dev/mapper/icp--<logical volume you create just now>--lv
<img src="imgs/example1.png">

2.

```bash
# Display Information about PVs ,LVs, VGs.
pvdisplay
vgdisplay
lvdisplay

# Commands to Scan PVs, LVs and VGs

pvscan
vgscan
lvscan
# Note: All these commands, work properly on Redhat/Centos/Ubuntu systems
```

<img src="imgs/example3.png">
