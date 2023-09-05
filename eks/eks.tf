module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.6.0"

  vpc_id     = aws_vpc.eks_cluster[0].id
  subnet_ids = aws_subnet.eks_private.*.id
  
  cluster_name    = local.names.eks_cluster
  cluster_version = local.var.cluster_version

  enable_irsa                          = true
  cluster_ip_family                    = local.cluster_ip_family
  cluster_endpoint_private_access      = true
  
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = concat(flatten(values(local.var.network.eks_endpoint_public_access_cidrs)))

  # DO NOT REMOVE
  # Removing this triggers EKS cluster recreation.
  cluster_security_group_name           = local.names.security_groups.cluster
  # cluster_additional_security_group_ids = [ aws_security_group.cluster_access_allow.id ]

  # if will create custom launch_template, do not create node security_group
  create_node_security_group = try(tobool(local.var.node_groups[0].create_launch_template), false) ? false : true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  create_kms_key            = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.this.arn
    resources        = ["secrets"]
  }

  eks_managed_node_group_defaults = {
    # See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.19.0/examples/eks_managed_node_group/main.tf#L99
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    for node_group in local.var.node_groups :
    "${local.prefix}-${node_group.name}" => merge(

      node_group.autoscaling,
      
      {
        use_custom_launch_template    = false
        instance_types                = node_group.instance_types
        disk_size                     = node_group.disk_size
        iam_role_additional_policies  = node_group.iam_role_additional_policies

        labels = {
          instance-type = "on-demand"
          node-group    = "${local.prefix}-${node_group.name}"
        }
      },

      # Remote access cannot be specified with a launch template
      (
        try(tobool(node_group.create_launch_template), false)
        ? null
        : {
          remote_access = {
            ec2_ssh_key               = aws_key_pair.k8s_nodes_generated_key.key_name
            source_security_group_ids = [aws_security_group.stub.id]
          }
        }
      ),

      (
        try(tobool(node_group.create_launch_template), false)
        ? {
          use_custom_launch_template            = true
          ami_type                              = "AL2_x86_64"
          ami_id                                = data.aws_ami.eks_default_arm.image_id
          instance_types                        = node_group.instance_types
          disk_size                             = node_group.disk_size
          enable_bootstrap_user_data            = true
          pre_bootstrap_user_data               = "${file("files/eks/kubelet-config.sh")}"
          attach_cluster_primary_security_group = true
          block_device_mappings = {
            xvda = {
              device_name = "/dev/xvda"
              ebs = {
                volume_size = node_group.disk_size
              }
            }
          }
        }
        : null
      )
    )
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_users = local.var.iam.eks_aws_auth_users

  aws_auth_roles = [
    # Link Admin role
    {
      rolearn  = aws_iam_role.eks_admin_access_role.arn
      username = aws_iam_role.eks_admin_access_role.name
      groups   = [local.names.k8s_rbac_admin_group]
    },
    # Link ViewOnly role
    {
      rolearn  = aws_iam_role.eks_viewonly_access_role.arn
      username = aws_iam_role.eks_viewonly_access_role.name
      groups   = [local.names.k8s_rbac_viewonly_group]
    }
  ]
}

# Used for not openning worker nodes
resource "aws_security_group" "stub" {
  vpc_id      = aws_vpc.eks_cluster[0].id
  name        = local.names.security_groups.stub
  description = "Used in conjunction to EKS module for not openning worker nodes access to everywhere."
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.var.cluster_version}-v*"]
  }
}
