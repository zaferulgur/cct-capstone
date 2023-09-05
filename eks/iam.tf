############ EKS ViewOnlyAccess IAM Entities ############
data "aws_iam_policy_document" "eks_viewonly_access_policy" {

    version     = "2012-10-17"
    statement {
        sid         = "EksViewOnlyAccessAllowPolicy"
        effect      = "Allow"
        resources   = [
            "arn:aws:eks:${local.var.region}:125378330806:cluster/${local.names.eks_cluster}"
        ]
        actions     = [
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:ListClusters",
            "eks:DescribeUpdate",
            "eks:ListUpdates",
            "eks:ListAddons",
            "eks:DescribeAddon",
            "eks:DescribeAddonVersions",
            "eks:DescribeFargateProfile",
            "eks:DescribeIdentityProviderConfig",
            "eks:ListFargateProfiles",
            "eks:ListIdentityProviderConfigs",
            "eks:ListTagsForResource"
        ]
    }
    statement {
        sid         = "EksViewOnlyAccessDenyPolicy"
        effect      = "Deny"
        resources   = [
            "*"
        ]
        actions     = [
            "secretsmanager:*"
        ]
    }
    statement {
        sid         = "AssumeEksViewOnlyAccessRole"
        effect      = "Allow"
        actions     = [
            "sts:AssumeRole"
        ]
        resources   = [
            "${aws_iam_role.eks_viewonly_access_role.arn}"
        ]        
    }
}

resource "aws_iam_role" "eks_viewonly_access_role" {
    
    name = "${local.names.eks_cluster}_eks-viewonly-access.role"
    assume_role_policy = jsonencode({
        Version     = "2012-10-17"
        Statement   = [
            {
                Effect      = "Allow"
                Action      = "sts:AssumeRole"
                Condition   = {}
                Principal   = {
                    AWS = "arn:aws:iam::125378330806:root"
                }
            }
        ]
    })
}

resource "aws_iam_group" "eks_viewonly_access_group" {

  name = "${local.names.eks_cluster}_eks-viewonly-access.group"
}

resource "aws_iam_group_policy" "eks_viewonly_access_group_policy" {

  name  = "${local.names.eks_cluster}_eks-viewonly-access.group_policy"
  group = aws_iam_group.eks_viewonly_access_group.name
  policy = data.aws_iam_policy_document.eks_viewonly_access_policy.json
}

resource "aws_iam_group_membership" "eks_viewonly_access_group_membership" {

  name  = "${local.names.eks_cluster}_eks-viewonly-access.group_membership"
  group = aws_iam_group.eks_viewonly_access_group.name
  users = local.var.iam.eks_viewonly_access_group_users
}

############ EKS AdminAccess IAM Entities ############
data "aws_iam_policy_document" "eks_admin_access_policy" {

    version     = "2012-10-17"
    statement {
        sid         = "EksAdminAccessAllowPolicy"
        effect      = "Allow"
        resources   = [
            "arn:aws:eks:${local.var.region}:125378330806:cluster/${local.names.eks_cluster}"
        ]
        actions     = [
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:ListClusters",
            "eks:DescribeUpdate",
            "eks:ListUpdates",
            "eks:ListAddons",
            "eks:DescribeAddon",
            "eks:DescribeAddonVersions",
            "eks:DescribeFargateProfile",
            "eks:DescribeIdentityProviderConfig",
            "eks:ListFargateProfiles",
            "eks:ListIdentityProviderConfigs",
            "eks:ListTagsForResource"
        ]
    }
    # statement {
    #     sid         = "EksAdminAccessDenyPolicy"
    #     effect      = "Deny"
    #     resources   = [
    #         "*"
    #     ]
    #     actions     = [
    #         "secretsmanager:*"
    #     ]
    # }
    statement {
        sid         = "AssumeEksAdminAccessRole"
        effect      = "Allow"
        actions     = [
            "sts:AssumeRole"
        ]
        resources   = [
            "${aws_iam_role.eks_admin_access_role.arn}"
        ]        
    }
}

resource "aws_iam_role" "eks_admin_access_role" {
    
    name = "${local.names.eks_cluster}_eks-admin-access.role"
    assume_role_policy = jsonencode({
        Version     = "2012-10-17"
        Statement   = [
            {
                Effect      = "Allow"
                Action      = "sts:AssumeRole"
                Condition   = {}
                Principal   = {
                    AWS = "arn:aws:iam::125378330806:root"
                }
            }
        ]
    })
}

resource "aws_iam_group" "eks_admin_access_group" {

  name = "${local.names.eks_cluster}_eks-admin-access.group"
}

resource "aws_iam_group_policy" "eks_admin_access_group_policy" {

  name  = "${local.names.eks_cluster}_eks-admin-access.group_policy"
  group = aws_iam_group.eks_admin_access_group.name
  policy = data.aws_iam_policy_document.eks_admin_access_policy.json
}

resource "aws_iam_group_membership" "eks_admin_access_group_membership" {

  name  = "${local.names.eks_cluster}_eks-admin-access.group_membership"
  group = aws_iam_group.eks_admin_access_group.name
  users = local.var.iam.eks_admin_access_group_users
}
