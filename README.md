# Slurm Cluster in Openstack
These ansible playbooks creates and manages a dynamically allocated slurm cluster in an Openstack cloud. The cluster is based on CentOS 8 and [OpenHPC 2.x](https://openhpc.community/downloads/).

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
2. Source the `openrc` file to configure access to the Openstack cloud. Confirm access by using the `openstack project list` command. The command should return a list of projects to which you have access in the Openstack cloud.

## Configure Cluster

### vars/main.yml ###
This yaml file defines variables that configure the cluster. The relevant ones are:
* Cluster
  * `cluster_name`: Use a name unique to your Openstack project. The playbooks identify cloud resources used by the cluster by this string in the resource names.
* Head Node
  * `head_node_flavor`: instance flavor of the head node.
  * `head_node_disk_size_gb`: disk size of the head node.
* Access
  * `ssh_public_keyfile` and `ssh_private_keyfile`: Full paths (no tilde) to matching ssh public and private keys for gain initial access to the cluster.
