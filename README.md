# Slurm Cluster in Openstack Cloud
These ansible playbooks create and manage a dynamically allocated slurm cluster in an Openstack cloud. The cluster is based on CentOS 8 and [OpenHPC 2.x](https://openhpc.community/downloads/). Slurm configurations are based on the work contained in (https://github.com/XSEDE/CRI_Jetstream_Cluster).

# Systems Requirements
1. Access to an Openstack cloud such as [Red Cloud](https://redcloud.cac.cornell.edu) at [Cornell University Center for Advanced Computing](https://www.cac.cornell.edu)
1. [`openrc` file](https://www.cac.cornell.edu/wiki/index.php?title=OpenStack_CLI#Download_OpenStack_RC_File) containing credentials for accessing Openstack cloud.
1. A computer with python 3.6 or later installed.
1. Clone this repo to your computer.

# Deploy Slurm Cluster
## Install Ansible
1. cd to the directory containing the repo. 
1. Run the `install_ansible.sh` command. 

To run the ansible playbooks described in the subsequent sections, you must first in the same terminal:
1. Activate the ansible python virtual environment using the `source ansible/bin/activate` command. 
2. Source in the Openstack cloud credentials in the `openrc` file. Confirm access by using the `openstack project list` command. The command should return a list of projects to which you have access in the Openstack cloud.

## Configure Cluster

### vars/main.yml ###
This yaml file defines variables that configure the cluster. The relevant ones are:

* Cluster
  * `cluster_name`: Use a name unique to your Openstack project. The playbooks identify cloud resources used by the cluster by this string in the resource names. After you set this variable initially, please do not change it. **Need to update the default values.**.

* Head Node
  * `head_node_flavor`: instance flavor of the head node.
  * `head_node_disk_size_gb`: disk size of the head node in GB.

* Access
  * `ssh_public_keyfile` and `ssh_private_keyfile`: Full paths (no tilde) to matching ssh public and private keys for initial access to the cluster. **Need to update the default values.**
  * `cluster_network_ssh_access`: Restrict ssh access to the cluster to this IP range, or enter `0.0.0.0/0` for no restrictions. Make sure this CIDR include the IP address of your computer so it can deploy the cluster!

* Networking
  * `cluster_network_dns_servers`: Enter the appropriate DNS server for your Openstack cloud. The default values are good for CAC Red Cloud.

* Compute Imaging Insance: create_compute_image.yml uses this instance and create the compute node image. The playbook will create and delete this instance as needed.
  * `compute_imaging_instance_flavor`: instance flavor of the compute imaging instance
  
* Compute Node: If you change any of the parameters in this section after the cluster is deployed, re-run the `provision_head_node.yml` and `create_compute_image.yml` playbook for the changes to take effect.
  * `compute_node_flavor` and `compute_node_cpus`: The flavor and CPU counts of a compute node. The CPU count must match the flavor or `slurmd` might fail to start on the compute node.
  * `compute_node_disk_size_gb`: disk size of the compute node in GB.
  * `max_compute_nodes`: maximum number of compute nodes the cluster can have. 
  * `slurm_suspend_time`: Number of seconds slurm waits before deleting an idle compute node instance.
  
## Deploy Cluster
Ansible playbooks are idempotent. After correcting an error or updating a variable, you should be able to run the playbooks as many times as needed.

* Create the head node by running the `create_head_node.yml` playbook: `ansible-playbook create_head_node.yml`
* Provision the head node by running the `provision_head_node.yml` playbook: `ansible-playbook provision_head_node.yml`. This playbook will take a while to run depending on your head node flavor as it installs user software packages (gcc 9, openmpi 4, etc.) that come with OpenHPC 2.x distribution.
* Build compute node image by running the `create_compute_image.yml` playbook. This playbook makes sure `compute_node_image` image does not already exist in the cloud and will fail if it does. Delete the pre-existing `compute_node_image` using the `openstack image delete <compute_node_image>` command if needed: `ansible-playbook create_compute_image.yml`

# Access the Cluster
You can gain initial access to the cluster by ssh to the head node's IP address as defined by the `image_init_user` variable in `vars/main.yml`. When you submit jobs to slurm using the `sbatch` or `srun` commands on the head node, slurm will create and delete compute node instances as defined by the `max_compute_nodes` and `slurm_suspend_time` variables.

# Clean Up
When you are done with the cluster, delete all cloud resources used by the cluster using the `destroy_cluster.yml` playbook: `ansible-playbook destroy_cluster.yml`. **Note: all data stored in the cluster will be lost, forever, unrecoverable.**
