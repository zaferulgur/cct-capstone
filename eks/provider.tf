terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }

    tfvars = {
      source  = "innovationnorway/tfvars"
      version = "0.0.1"
    }

  }

  backend "s3" {
    # S3 Bucket Configs
    bucket  = "zu-terraform-statefile"
    key     = "terraform.tfstate"
    region  = "eu-west-1"

    # DynamoDB table Configs
    dynamodb_table = "zu-terraform-statefile-lock"
    encrypt        = true
  }
}

provider "tfvars" {}

provider "aws" {
  profile     = local.names.aws_profile_name
  region      = local.var.region

  default_tags {
    tags = local.default_tags
  }
}


resource "aws_s3_bucket" "aws_s3_tfstate" {
  bucket = "zu-terraform-statefile"
}

resource "aws_s3_bucket_ownership_controls" "aws_s3_tfstate_ownership" {
  bucket = aws_s3_bucket.aws_s3_tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aws_s3_tfstate_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.aws_s3_tfstate_ownership]

  bucket = aws_s3_bucket.aws_s3_tfstate.id
  acl    = "private"
}




resource "aws_dynamodb_table" "zu-terraform-statefile-lock" {
  name = "zu-terraform-statefile-lock"
  hash_key = "LockID"
  read_capacity = 5
  write_capacity = 5
 
  attribute {
    name = "LockID"
    type = "S"
  }
}


data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.var.region]
    }
  }
}
