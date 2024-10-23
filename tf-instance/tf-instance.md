- [Task: Use Terraform add an AWS security group](#task-use-terraform-add-an-aws-security-group)
  - [AWS security group](#aws-security-group)
- [Task: Use variables for all values supplied to app EC2 instance](#task-use-variables-for-all-values-supplied-to-app-ec2-instance)
  - [Can you SSH in?](#can-you-ssh-in)
- [Research](#research)
  - [What is pull and push configuration management (IaC)?](#what-is-pull-and-push-configuration-management-iac)
    - [Pull configuration management](#pull-configuration-management)
    - [Push configuration management](#push-configuration-management)
  - [Which tools support push/pull?](#which-tools-support-pushpull)
    - [Pull-based tools](#pull-based-tools)
    - [Push-based tools](#push-based-tools)
  - [Does Terraform use the push or pull configuration?](#does-terraform-use-the-push-or-pull-configuration)
  - [Which is better: push or pull configuration management?](#which-is-better-push-or-pull-configuration-management)
    - [Push model](#push-model)
    - [Pull model](#pull-model)


## Writing Terraform Code
For reference, see main.tf file. 
* create an EC2 instance.
  * Where to create - provide the provider.
  * which region to use to create infrastructure
  * which service/resources to create.
  * which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts).
  * what type of instance to lauch -t2.micro.
  * add a public IP to this instance. 
  * give a name to the service/resource we create

```bash
# aws_access_key= xxxx MUST NEVER DO THIS  
# aws_secret_key = xxx MUST NEVER DO THIS
# syntax often used in HCL is key = value

# create an EC2 instance.
# Where to create - provide the provider.

provider "aws" {
  # which region to use to create infrastructure
  region = "eu-west-1"
}

# which service/resources to create.

resource "aws_instance" "app_instance" {
  # which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)).
  ami = "ami-0c1c30571d2dae5c9"

  # what type of instance to lauch -t2.micro.
  instance_type = "t2.micro"

  # add a public IP to this instance. 
  associate_public_ip_address = true

  # give a name to the service/resource we create
  tags = {
    Name = "tech264-georgia-tf-app-instance"
  }

}
```

<br>

## Using the 4 commands.

* Make sure your work on VSC is saved, otherwise it can't initialise. 
* `terraform init`
* Go into your tech264-terraform repo and `ls` to check you main.tf file is present. 

![alt text](../terraform-images/terraform-init.png)

<br>

* Make sure everything is saved on VSC.
* `terraform fmt`
* This is to make sure your formatting within the main.tf file is correct, ensuring that Terraform can read it. 

![alt text](../terraform-images/terraform-fmt.png)

<br>

* Make sure everything is saved on VSC.
* `terraform plan`
* This can take a moment, please be patient. 
* 
![alt text](../terraform-images/terraform-plan.png)
![alt text](../terraform-images/plan-ending.png)

* If we were dong a CICD pipeline, it would be a good idea to save the plan.

<br> 

* Make sure everything is saved on VSC.
* `terraform apply`

![alt text](../terraform-images/perform-plan.png)

* Enter a value: "yes" (if you're happy with the plan). 
* Now it's creating the EC2 instance. 

![alt text](../terraform-images/enter-value.png)

* Go to AWS > EC2 > Instances to check if it's worked!

![alt text](../terraform-images/instances.png)

<br>

* time to destroy everything!
* `terraform destroy`
* "Enter a value": yes
  * You'll notice that on AWS, the instance does not exist anymore. 

![alt text](../terraform-images/destroy.png)
![alt text](../terraform-images/destroy-complete.png)
![alt text](../terraform-images/deleted-instances.png)

<br>

# Task: Use Terraform add an AWS security group
Using Terraform and Terraform official documentation:

## AWS security group
* In your Create an AWS security group named tech2xx-firstname-tf-allow-port-22-3000-80 (tf so you know it was created by Terraform)
  * Allow port 22 from localhost
  * Allow port 3000 from all
  * Allow port 80 from all

```bash
# create an EC2 instance.
# Where to create - provide the provider.

provider "aws" {
  # which region to use to create infrastructure
  region = "eu-west-1"
}

# which service/resources to create.
resource "aws_security_group" "tech264_georgia" {
  name        = "tech2xx-georgia-tf-allow-port-22-3000-80"
  description = "Security group created by Terraform"

  ingress {
    description = "Allow SSH from localhost"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow application traffic on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tech264-georgia-tf-app-instance"
  }
}
```

* Make sure the folder has been `terraform init`.
* format: `terraform fmt`
* plan: `terraform plan`
* apply: `terraform apply`

* Check its been created on AWS security groups

![alt text](../terraform-images/aws-sg.png)

* destroy: `terraform destroy`

<br>

* Modify the EC2 instance created in main.tf:
  * Attach the key to be used with EC2 instance
  * Use security group you created
  * Test infrastructure was created as intended

```bash
# create an EC2 instance.
# Where to create - provide the provider.

provider "aws" {
  # which region to use to create infrastructure
  region = "eu-west-1"
}

resource "aws_instance" "app_instance" {
  # which AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)).
  ami = var.app_ami_id

  # what type of instance to lauch -t2.micro.
  instance_type = "t2.micro"

  # ssh key (.prm on file)
  key_name = "tech264-georgia-aws-key"

  # add security group 
  vpc_security_group_ids = [aws_security_group.tech264_georgia.id]


  # give a name to the service/resource we create
  tags = {
    Name = "tech264-georgia-tf-app-instance"
  }

}
```
![alt text](../terraform-images/aws-instane.png)

<br>

# Task: Use variables for all values supplied to app EC2 instance 
* go to main.tf file. 
* add a variables to main.tf
> Below are some examples.

![alt text](../terraform-images/var-eg.png)

<br> 

## Can you SSH in?
* Go to AWS Instance and "Connect". 
* SSH into the instance.
  * cd > .ssh
  * paste connection key. 

![alt text](../terraform-images/ssh-in.png)

<br>

# Research
## What is pull and push configuration management (IaC)?
### Pull configuration management 
* In a pull model, each target machine (like a server) pulls its configuration from a central server or management system. 
* This happens periodically, where the machines use an agent to check and update their own configurations as needed. 
* This method is common in continuous management where machines need to stay up-to-date with the latest policies and configurations.

* Example: Puppet and Chef use this approach. Agents installed on machines reach out to a central server to fetch their latest configurations.

### Push configuration management 
* In a push model, the controlling server pushes configurations directly to the target machines. 
* This is usually done over a connection like SSH and does not require an agent running on the target machines. 
* This method is more direct and is often used when you need to apply changes immediately.

* Example: Ansible, Terraform, and AWS CloudFormation use this approach. The controlling system (like a laptop running Terraform) pushes the infrastructure changes to the target cloud providers or servers​ DEV COMMUNITY, ENCORA, PUPPETEERS.

<br>

## Which tools support push/pull?
### Pull-based tools
* Puppet and Chef: Both use agents on machines that pull configurations periodically from a central server.

### Push-based tools
* Ansible: Pushes changes directly from the controlling machine to the targets over SSH.
* Terraform: Pushes changes to cloud infrastructure via API calls, making it more declarative but push-based.
* AWS CloudFormation: Also uses a push model when managing AWS infrastructure​ DEV COMMUNITY, CLOUD TRAINING PROGRAM, PUPPETEERS.

<br>

## Does Terraform use the push or pull configuration?
* Terraform uses the push model. 
* It defines the desired state of infrastructure in code and then pushes the configuration changes to cloud providers like AWS using their APIs. 
* This means it does not require an agent on the target systems, but rather directly interacts with APIs to apply the changes​ PUPPETEERS.


## Which is better: push or pull configuration management?
There’s no definitive "better" model—it depends on the use case:

### Push model 
* Is typically better for provisioning infrastructure and when you need immediate application of changes. 
* Tools like Terraform or Ansible excel in this for cloud infrastructure or one-time setups.

### Pull model 
* Is often better for continuous configuration management, where systems need to regularly check in and stay updated with the latest configurations. 
* Tools like Puppet and Chef are ideal for this.

> In short:
> 
> If you need ongoing, regular configuration updates, pull tools might be a better fit.
> 
> If you need to set up infrastructure or apply changes instantly, push tools are often more efficient​
ENCORA, CLOUD TRAINING PROGRAM, PUPPETEERS.