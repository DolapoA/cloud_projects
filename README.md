# Cloud Projects
A portfolio of cloud projects using Infrastructure as Code (IaC)
Herein is a terse description of the activity undertaken in each project and the corresponding method of what was done on the CLI.
Project titles here are virtually identical to their corresponding repository folders.

## Project 1: Learn Terraform Docker Container

### Activity
1. Install terraform
2. Verify the installation
3. Enable tab autocompletion
4. Provision and destroy an NGINX server

---
### Method
1. `brew tap hashicorp/tap` -> `brew tap hashicorp/tap` -> `brew install hashicorp/tap/terraform` -> `brew update` -> `brew upgrade hashicorp/tap/terraform`
2. terraform --help
3. `terraform -install-autocomplete`
4. Start docker -> `open -a Docker`
   - create the `main.tf` inside the relevant folder (earn-terraform-docker-container)
   - terraform init
   - terraform apply
   - check the container -> `docker ps`
   - `terraform destroy`
   
---


## Project 2: Learn Terraform AWS Instance (learn-terraform-aws-instance)

### Activity
1. Spin up a Debian EC2 instance
2. Replace the Debian instance with an Ubuntu instance which is dynamically chosen to be the latest version
3. Destroy the Ubuntu EC2 instance

---
### Method
1. `terraform init` -> `terraform fmt` -> `terraform validate` -> `terraform apply`
   - Inspect the state of the EC2 instance -> `terraform show`
   - List resources in the project's state -> `terraform state list`
2. Add a data block to filter for the latest Ubuntu AMI
3. `terraform destroy`

---


## Project 3: Define Input Variables (learn-terraform-aws-instance)

### Activity
1. Create variables.tf file to define EC2 instance name dynamically
2. Change instance name whilst provisioning the EC2 instance


---
### Method
1. `touch variables.tf`
2. `terraform apply -var "instance_name=YetAnotherName"`


---


## Project 4: Query data with outputs (learn-terraform-aws-instance)

### Purpose
To be able to use these outputs to connect this component of infrastructure with other components of infrastructure e.g. Amazon S3.


### Activity
1. Create outputs.tf file to define the output EC2 instance configuration
2. Query the outputs


---
### Method
1. `touch outputs.tf`
2. `terraform output`


---


## Project 5: Store Remote State

### Purpose
To use HCP Terraform to keep the infrastructure state secure and encrypted in a place that collaborators can access and where Terraform can run remotely.


### Activity
1. Login to terraform
2. Having logged in, initialise terraform
3. Migrate the state file
4. Having migrated the state file to HCP Terraform, delete the local state file
5. Set workspace variables in HCP Terraform 


---
### Method
1. `terraform login`
2. `terraform init`
3. `terraform init`
4. `rm terraform.tfstate`
5. Login to HCP Terraform to do this


---