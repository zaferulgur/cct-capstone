data "tfvars_file" "env" {
  filename = "./variables/${terraform.workspace}.tfvars"
}

# variable "helm_registry_aws_access_key_id" {
#   type = string
# }

# variable "helm_registry_aws_secret_key" {
#   type = string
# }
