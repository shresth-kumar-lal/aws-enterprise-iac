# Enterprise ready AWS Infrastructure as Code (IaC) Architecture

This repository contains the Terraform source code to provision a highly available, secure network and web server architecture in AWS (`ap-south-1`). 

It demonstrates Zero-Trust networking principles, multi-AZ fault tolerance, and declarative state management.

## Architecture & Security

```mermaid
flowchart TB
    User((Internet User))

    subgraph AWS ["AWS Cloud (ap-south-1)"]
        direction TB
        
        subgraph Backend ["Terraform Backend"]
            S3[(S3 State Bucket)]
            DDB[(DynamoDB Lock)]
        end

        IGW[Internet Gateway]

        subgraph VPC ["Enterprise VPC (10.0.0.0/16)"]
            ALB{{Application Load Balancer}}
            
            subgraph AZ1 ["Availability Zone: ap-south-1a"]
                subgraph Pub1 ["Public Subnet 1 (10.0.1.0/24)"]
                    NAT[NAT Gateway]
                end
                subgraph Priv1 ["Private Subnet 1 (10.0.11.0/24)"]
                    ASG1[EC2 Web Server]
                end
            end

            subgraph AZ2 ["Availability Zone: ap-south-1b"]
                subgraph Pub2 ["Public Subnet 2 (10.0.2.0/24)"]
                    Blank[ ]
                    style Blank fill:none,stroke:none
                end
                subgraph Priv2 ["Private Subnet 2 (10.0.12.0/24)"]
                    ASG2[EC2 Web Server]
                end
            end
        end
    end

    %% Ingress Traffic Flow
    User -->|HTTP 80| IGW
    IGW --> ALB
    ALB -->|Forward via Target Group| ASG1
    ALB -->|Forward via Target Group| ASG2

    %% Egress Traffic Flow (Updates/Patches)
    ASG1 -.->|Outbound| NAT
    ASG2 -.->|Outbound| NAT
    NAT -.-> IGW

    %% Styling
    style AWS fill:#f9f9f9,stroke:#FF9900,stroke-width:2px,color:#000
    style VPC fill:#e6f0fa,stroke:#3b48cc,stroke-width:2px,color:#000
    style Pub1 fill:#e6ffe6,stroke:#2ca02c,stroke-dasharray: 5 5,color:#000
    style Pub2 fill:#e6ffe6,stroke:#2ca02c,stroke-dasharray: 5 5,color:#000
    style Priv1 fill:#ffe6e6,stroke:#d62728,stroke-dasharray: 5 5,color:#000
    style Priv2 fill:#ffe6e6,stroke:#d62728,stroke-dasharray: 5 5,color:#000
```

* **State Locking (The Backend):** Configured to use a remote S3 bucket for state storage and a DynamoDB table for strict state-locking, preventing concurrent pipeline mutations.
* **The VPC (Network Isolation):** A custom Virtual Private Cloud spanning two Availability Zones in Mumbai (`ap-south-1a`, `ap-south-1b`).
* **The Public Tier (Ingress):** Houses the Application Load Balancer (ALB), an Internet Gateway, and NAT Gateways.
* **The Private Tier (Zero Trust):** Houses an Auto Scaling Group (ASG) of web servers. **Security Posture:** The web servers reside in private subnets with no public IP addresses. Their Security Group explicitly denies all inbound traffic except from the ALB. Outbound traffic is securely routed through a NAT gateway for system updates.

## Repository Structure

* `providers.tf` - AWS Provider configuration and Remote Backend setup.
* `variables.tf` - Dynamic parameters (CIDR blocks, Regions).
* `network.tf` - VPC, Public, and Private Subnet provisioning.
* `gateways.tf` - Internet Gateway, NAT Gateway, and Route Tables.
* `security.tf` - Ingress/Egress Security Groups for ALB and EC2 instances.
* `compute.tf` - Auto Scaling Group, ALB, and dynamic AMI fetching (Ubuntu 24.04).

## Execution & Validation

This code has been strictly formatted (`terraform fmt`), validated (`terraform validate`), and successfully planned against the live AWS API.

**Execution Plan Output:**
```bash
$ terraform plan
...
Plan: 21 to add, 0 to change, 0 to destroy.
