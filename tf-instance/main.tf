# aws_access_key= xxxx MUST NEVER DO THIS  
# aws_secret_key = xxx MUST NEVER DO THIS
# syntax often used in HCL is key = value

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
  instance_type = var.instance_type

  # ssh key (.prm on file)
  key_name = var.key_name

  # add security group 
  vpc_security_group_ids = [aws_security_group.tech264_georgia.id]


  # give a name to the service/resource we create
  tags = {
    Name = "tech264-georgia-tf-app-instance"
  }

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
    cidr_blocks = ["0.0.0.0/0"] # Open to the world (use causiously)
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


