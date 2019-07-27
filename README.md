# Tank Terraform

IMPORTANT: don't forget to destroy after experiment:  
`terraform destroy`

## Tank Terraform AWS

Terraform workflow to AWS and Ansible Inventory file template

This repo uses submodules. For cloning use `git clone --recursive`.

The following steps are needed to setup a Tank database:

* You will need a working AWS CLI (setup using `aws configure`).
* Set necessary variables in `terraform.tfvars`. The docker login is needed to pull the tank image.
* Keyfile `~/.ssh/id_rsa` is used by default, otherwise set `keyfile` variable in `.tfvars`.
* Set number of nodes, instance_type or other variables as needed.
* `terraform init` to setup terraform environment
* `terraform apply` so setup infrastructre in AWS
* Wait until instances are running
* `ansible-playbook -i ./tank-ansible/aws-hosts tank-ansible/site.yml` to provision tank and needed components on nodes.
* A simple NGINX load balancer is then running on the first EC2 instance.
* `terraform state show aws_instance.gateway` prints the state including the FQDN (public_dns) of the public endpoint.

## Tank Terraform Azure

Terraform workflow to Azure and Ansible Inventory file template

This repo uses submodules. For cloning use `git clone --recursive`.

The following steps are needed to setup a Tank database:

* You will need a working AZ CLI (setup using `az login`).
* Set necessary variables in `terraform.tfvars`. The docker login is needed to pull the tank image.
* Set number of nodes, instance_type or other variables as needed.
* `terraform init` to setup terraform environment
* `terraform apply` so setup infrastructre in Azure
* Wait until instances are running
* `ansible-playbook -i ./tank-ansible/azure-hosts tank-ansible/site.yml` to provision tank and needed components on nodes.
* A simple NGINX load balancer is then running on the first Azure Virtual Machine instance.

## Tank Terraform OpenStack

Terraform workflow to OpenStack and Ansible Inventory file template

This repo uses submodules. For cloning use `git clone --recursive`.

The following steps are needed to setup a Tank database:

* You will need a working OpenStack CLI (setup using `source ./PROJECT-openrc.sh`).
* Set necessary variables in `terraform.tfvars`. The docker login is needed to pull the tank image.
* Set number of nodes, instance_type or other variables as needed.
* `terraform init` to setup terraform environment
* `terraform apply` so setup infrastructre in OpenStack
* Wait until instances are running
* `ansible-playbook -i ./tank-ansible/openstack-hosts tank-ansible/site.yml` to provision tank and needed components on nodes.
* A simple NGINX load balancer is then running on the first OpenStack instance.
