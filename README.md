
# AWS DevOps Project – Scalable Containerized Infrastructure

## Project Overview

This project provisions a **scalable, secure, and containerized AWS infrastructure using Terraform**, automating the deployment of a React application with Docker, RDS database instances (MySQL and PostgreSQL), Application Load Balancer (ALB), and custom domain with SSL configuration. The architecture also includes setup for a BI tool on a separate EC2 instance (work in progress).

---

## Repository Structure

```
/DevOps_Project
│
├── main.tf              # Terraform main configuration file
├── variables.tf         # Variables used in Terraform scripts
├── alb.tf               # Load balancer configuration in AWS
├── outputs.tf           # Output values after Terraform apply
├── route53.tf           # Domain setup for app deployment
├── security_groups.tf   # Security groups for instances
├── target_groups.tf     # Target groups after Terraform apply
├── ec2.tf               # EC2 instances' creation configuration
├── al2_userdata.sh      # EC2 User Data script for Docker & app setup
├── bi_userdata.sh       # User Data script for BI tool (WIP)
├── rds.tf               # RDS instances' creation configuration
└── README.md            # Project documentation and setup instructions
```

---

## Prerequisites

1. **AWS CLI** (configured)
2. **Terraform v1.5+**
3. **Git**
4. **An AWS Account** with necessary IAM permissions
5. **SSH Key Pair** (for accessing EC2)
6. **Registered Domain** (Already setup: `sumbal-project.apparelcorner.shop`)

---

## Setup Instructions

### 1. Clone this Repository

```bash
git clone https://github.com/sumbal-dot/DevOps_Project.git
cd DevOps_Project
```

---

### 2. Configure AWS CLI

Make sure your AWS CLI is configured:

```bash
aws configure
```

---

### 3. Initialize Terraform

```bash
terraform init
```

---

### 4. Customize Variables (Optional)

Edit `variables.tf` to modify region, or desired capacity as per your requirement.

---

### 5. Plan Terraform Deployment

```bash
terraform plan
```

---

### 6. Apply Terraform Configuration

```bash
terraform apply
```

**Note**: Type `yes` to confirm resource creation.

---

### 7. Access the Application

- **Application URL (with SSL):**  
  https://sumbal-project.apparelcorner.shop (currently down as the instances have been shut down)

- The ALB will route incoming HTTPS traffic to the EC2 Auto Scaling Group hosting the Dockerized React App.

---

### 8. Database Access

- **MySQL & PostgreSQL RDS Instances**:  
  Accessible only from EC2 instances inside the VPC.
  
- For local DB management via tools like **DBeaver**, set up **SSH tunneling** through the application EC2 instance:

```bash
ssh -i <your-key.pem> ec2-user@<EC2-Public-IP> -L 3306:<RDS-MySQL-Endpoint>:3306
ssh -i <your-key.pem> ec2-user@<EC2-Public-IP> -L 5432:<RDS-Postgres-Endpoint>:5432
```

Then connect using `localhost:3306` (MySQL) or `localhost:5432` (PostgreSQL).

---

### 9. BI Tool Deployment (In Progress)

A separate EC2 instance for BI tools (e.g., Metabase or Redash) is provisioned but final deployment but is pending.

---

## Cleanup Resources

To avoid charges, destroy the provisioned infrastructure after use:

```bash
terraform destroy
```

---

## Loom Videos (Demonstration)

- **Infrastructure Provisioning & SSL Access**:  
  [Watch here](https://www.loom.com/share/cbbd4b071d364617af88024c4ef1c0af?sid=5de7f66c-315d-4eac-a7f5-21d0b6a58f16)

- **Database Connection via SSH Tunnel**:  
  [Watch here](https://www.loom.com/share/1f4136fdaa474f2e949eaf3a6c991c62?sid=322f0d79-83b6-45f3-8f54-4c2579942d26)

---

## Notes

- The **Dockerfile** is generated inside the EC2 instances through `userdata.sh` and is not included in this repository.
- Ensure your AWS billing is monitored as some resources may incur charges.
