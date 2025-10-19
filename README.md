# Sample App Infrastructure

Provisioned with Terraform to deploy:
- VPC (public/private)
- EKS cluster (t3.medium nodes)
- Jenkins EC2 in private subnet
- Squid proxy for outbound access
- ALB for Jenkins UI
- Node.js app deployment to EKS via Jenkins + DockerHub

## Commands
```bash
cd infra
terraform init
terraform apply

ran 
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

