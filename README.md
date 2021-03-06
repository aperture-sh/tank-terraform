# Tank Terraform

IMPORTANT: don't forget to destroy after experiment:  
`terraform destroy --var-file <provider>/terraform.tfvars <provider>`

The Tank infrastructure is ready to be deployed in the AWS, Microsoft Azure and OpenStack cloud platforms.
Terraform provisions the infrastructure and Ansible will setup the needed software components.

![](assets/img/azure-logo.png)
![](assets/img/aws-logo.png)
![](assets/img/openstack-logo.png)

* This repo uses submodules. For cloning use `git clone --recursive`
* Keep in mind only one cloud can be used in one terraform workspace

The following steps are needed to setup everything up:

## Amazon Web Services (AWS)

* You will need a working AWS CLI (setup using `aws configure`).
* Set necessary variables in `./aws/terraform.tfvars`. The docker login is needed to pull the tank image.
* Keyfile `~/.ssh/id_rsa` is used by default, otherwise set `keyfile` variable in `.tfvars`.
* Set number of nodes, instance_type or other variables as needed.
* `terraform init ./aws` to setup terraform environment
* `terraform apply --var-file aws/terraform.tfvars aws` so setup infrastructre in AWS


## Microsoft Azure

* You will need a working AZ CLI (setup using `az login`).
* Set necessary variables in `./azure/terraform.tfvars`. The docker login is needed to pull the tank image.
* Set number of nodes, instance_type or other variables as needed.
* `terraform ini ./azure` to setup terraform environment
* `terraform apply --var-file azure/terraform.tfvars azure` so setup infrastructre in Azure

## OpenStack

* You will need a working OpenStack CLI (setup using `source ./PROJECT-openrc.sh`).
* Set necessary variables in `./openstack/terraform.tfvars`. The docker login is needed to pull the tank image.
* Set number of nodes, instance_type or other variables as needed.
* `terraform init ./openstack` to setup terraform environment
* `terraform apply --var-file openstack/terraform.tfvars openstack` so setup infrastructre in OpenStack

## Ansible Component Provisioning

* Wait until instances are running
* `ansible-playbook -i ./ansible/cloud-hosts ansible/site.yml` to provision tank and needed components on nodes.
* A simple NGINX load balancer is then running on the gateway virtual machine.
