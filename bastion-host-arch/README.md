# AWS Bastion Host Architecture using Terraform

## Short Description
This Terraform project provisions a basic AWS network architecture that demonstrates a secure **bastion host pattern**. It creates a VPC with public and private subnets, where a public EC2 instance (bastion) is used to access a private EC2 instance that is not directly reachable from the internet.

---

## High-Level Flow
1. A user SSHs into the **public EC2 instance (bastion host)** from their local machine.
2. The bastion host acts as the controlled entry point inside the VPC.
3. From the bastion, the user connects to the **private EC2 instance** using its private IP.
4. The private instance remains isolated from direct internet access.

---

## What This Code Creates

- A custom **VPC** with a defined CIDR block
- One **public subnet** (for bastion host)
- One **private subnet** (for private EC2 instance)
- An **Internet Gateway** attached to the VPC
- A **public route table** with internet access via IGW
- A **private route table** with only internal VPC routing
- Route table associations for both subnets
- Two **security groups**:
  - One allowing SSH/ICMP from the internet (bastion host)
  - One allowing SSH/ICMP only from within the VPC (private instance access)
- An **EC2 bastion host** in the public subnet
- An **EC2 private instance** in the private subnet
- A **key pair** for SSH access
- An **S3 backend** for Terraform state storage
- A **DynamoDB table** for Terraform state locking
- Output values for public and private instance IPs