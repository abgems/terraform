# terraform
In this project, I provisioned AWS infrastructure using Terraform, an Infrastructure as Code (IaC) tool. The following services were provisioned:

1. VPC with two subnets  
2. Internet Gateway and Route Table  
3. Route Table associations with subnets and gateway  
4. Security Groups for ingress and egress rules  
5. Two EC2 instances  
6. S3 Bucket  
7. Application Load Balancer (ALB) with listeners  
8. Load Balancer target groups attached to EC2 instances  

The ALB routes traffic to the EC2 instances, which host an Apache2 application. Proper listeners were configured for the ALB.
