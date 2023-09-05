data "tfvars_file" "env" {
  filename = "./variables/${terraform.workspace}.tfvars"
}
