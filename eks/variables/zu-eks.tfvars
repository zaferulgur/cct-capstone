########################### General Variables ###########################
region                = "eu-west-1"
region_name           = "ireland"
platform              = "zu"
environment           = "poc"


########################### EKS Cluster Variables ###########################
cluster_version                       = "1.26"
iam_eks_role_cluster_autoscaler_name  = "EKSClusterAutoscaler"
iam_eks_role_lb_name                  = "EKSLoadBalancer"

node_groups = [
  {
    name                    = "v1"
    disk_size               = 30
    instance_types          = ["t3.medium"]
    create_launch_template  = "false"

    autoscaling = {
      desired_size = 2
      min_size     = 1
      max_size     = 3
    }

    iam_role_additional_policies  = {
      AmazonEBSCSIDriverPolicy      = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }
]


########################### EKS Cluster AddOn Apps Installation Flags ###########################
flags = [
  "create_network",
  "install_metrics_server",
  "install_nginx_ingress_controller_external",
]


########################### IAM Variables ###########################
iam = {
  eks_aws_auth_users = [
    {
      userarn  = "arn:aws:iam::125378330806:user/terraform"
      username = "terraform"
      groups   = [ "terraform-viewonly-group" ]
    }
  ]

  eks_viewonly_access_group_users = [
  ]

  eks_admin_access_group_users = [
    "burak.kose",
    "zafer.ulgur",
  ]
}


########################### Network Variables ###########################
network = {

  vpc = {
    cidr          = "10.96.0.0/16"
    prefix_subnet = "10.96"
  }

  routes = {
    # transit_gateway = {
    #   id = "tgw-06f31e1bffc246e7a"  # London-Transit-Gateway-01
    #   cidr_blocks = []
    # }
  }

  allowed_cidrs_to_access_cluster = []

  # If need to access EKS cluster from public network, add the public ip in the below list
  eks_endpoint_public_access_cidrs = {
    external_ips = [
      "80.111.103.67/32",   # External IP of Zafer.Ulgur
      "178.244.135.95/32",  # External IP of Burak.Kose
    ]
  }

  eks_endpoint_public_access_ec2_instances = []

  route53 = {
    external_domain = {
      zone_name = "zu-cct-capstone.online"
    }
  }
}

########################### Setup Configuration Variables ###########################
setup_configs = {
  fluent_bit = {
    # eks_app_index   = "Define an index for the running apps on the eks cluster!"
    # eks_infra_index = "Define an index for the running as infra based apps on the eks cluster!"
    # es_url          = "Define the target ElasticSearch URL!"
    # es_user         = "Define the target ElasticSearch Username!"
    # es_password     = "Define the target ElasticSearch Password! Ex:${eks_es_password}"
  }
}
