# Terraform Automated Flask Deployment
This project automates the creation of a complete AWS infrastructure and deploys a Flask application using Terraform provisioners.

# What this project builds:
VPC, Public Subnet, and Internet Gateway.

Security Groups for SSH (22) and HTTP (80).

Ubuntu EC2 Instance with a key pair.

Automation with Provisioners:

file provisioner: Transfers app.py from your local machine to the EC2 instance.

remote-exec provisioner: Executes shell commands via SSH to install Python/Flask and run the app in the background.

# Prerequisites
AWS CLI configured with the credentials.

Terraform installed on local machine.

An existing AWS Key Pair 

# How to deploy:
Initialize: terraform init

Apply: terraform apply 

Access: Visit http://<EC2_PUBLIC_IP> to see app running.

# Cleanup:
Always destroy resources after testing to avoid costs:
terraform destroy 
