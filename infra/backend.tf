terraform {
  backend "s3" {
    bucket = "terraform-eks-din"
    key = "statefiles/sample-app/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}
