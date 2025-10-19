terraform {
  backend "s3" {
    bucket         = "terraform-task-eks"        # <-- your new bucket
    key            = "statefiles/sample-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-task-eks"       # <-- ensure this is NEW or EMPTY
    encrypt        = true
  }
}

