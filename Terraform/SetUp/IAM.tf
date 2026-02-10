###################################################################
# Create IAM user and policies for continuous deploy (CD) account #
###################################################################
resource "aws_iam_user" "cd" {
  name = "devops-cd-user"
}
#######################
# Creating Access Key #
#######################
resource "aws_iam_access_key" "cd" {
  user = aws_iam_user.cd.name
}
#####################################################################################################################################################
###################################################################
#Define policy for Terraform backend to S3 and DynamoDB access #
###################################################################

data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}/tf_state_deploy/staging/*",
      "arn:aws:s3:::${var.tf_state_bucket}/Big-Pro-SetUP/*",
      "arn:aws:s3:::${var.tf_state_bucket}/state-Big-Pro-SetUP-Deploy/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:PutObject",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/${var.terraform-state-locking}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeRegions",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

##################
# Create Plolicy #
##################
resource "aws_iam_policy" "tf_backend" {
  name        = "${aws_iam_user.cd.name}-tf-s3-dynamodb"
  description = "allow user to use s3 and Dynamodb for tf Backend"
  policy      = data.aws_iam_policy_document.tf_backend.json
}
#####################
# Attach the policy #
#####################

resource "aws_iam_user_policy_attachment" "tf_backend" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.tf_backend.arn
}

########################################################################################################################################
########################
# Policy for ECR access #
########################

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.ECR.arn,
      aws_ecr_repository.ECR_Proxy.arn,
    ]
  }
}

##################
# Create Plolicy #
##################
resource "aws_iam_policy" "ecr" {
  name        = "${aws_iam_user.cd.name}-ecr"
  description = "allow user to use ECR "
  policy      = data.aws_iam_policy_document.ecr.json
}

#####################
# Attach the policy #
#####################

resource "aws_iam_user_policy_attachment" "ecr" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.ecr.arn
}


##################################################################################################################################

##########################
# Policy for EC2 access #
##########################

data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeSecurityGroups",
      "ec2:DeleteSubnet",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:DeleteInternetGateway",
      "ec2:DetachNetworkInterface",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRouteTables",
      "ec2:DeleteRouteTable",
      "ec2:DeleteVpcEndpoints",
      "ec2:DisassociateRouteTable",
      "ec2:DeleteRoute",
      "ec2:DescribePrefixLists",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeNetworkAcls",
      "ec2:AssociateRouteTable",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:CreateVpcEndpoint",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateSubnet",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:ModifyVpcAttribute",
      "ec2:RevokeSecurityGroupIngress",
    ]
    resources = ["*"]
  }
}

##################
# Create Plolicy #
##################
resource "aws_iam_policy" "ec2" {
  name        = "${aws_iam_user.cd.name}-ec2"
  description = "allow user to use ec2 resources "
  policy      = data.aws_iam_policy_document.ec2.json
}

#####################
# Attach the policy #
#####################

resource "aws_iam_user_policy_attachment" "ec2" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.ec2.arn
}


#########################
# Policy for RDS access #
#########################
data "aws_iam_policy_document" "rds" {
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBInstances",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:AddTagsToResource",
      "rds:ListTagsForResource",
      "rds:ModifyDBInstance",
      "rds:RemoveTagsFromResource",
      "rds:DescribeEvents",
      "rds:DescribeOrderableDBInstanceOptions",
      "rds:DescribeDBEngineVersions",
      "rds:DescribeDBParameterGroups",
      "rds:DescribeDBParameters"
    ]
    resources = ["*"]
  }
}

##################
# Create Plolicy #
##################
resource "aws_iam_policy" "rds" {
  name        = "${aws_iam_user.cd.name}-rds"
  description = "allow user to use rds resources "
  policy      = data.aws_iam_policy_document.rds.json
}

#####################
# Attach the policy #
#####################

resource "aws_iam_user_policy_attachment" "rds" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.rds.arn
}

#########################
# Policy for ECS access #
#########################

data "aws_iam_policy_document" "ecs" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DeregisterTaskDefinition",
      "ecs:DeleteCluster",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:DescribeTaskDefinition",
      "ecs:CreateService",
      "ecs:TagResource",
      "ecs:UntagResource",
      "ecs:ListTagsForResource",
      "ecs:RegisterTaskDefinition",
      "ecs:CreateCluster",
      "ecs:UpdateCluster",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs" {
  name        = "${aws_iam_user.cd.name}-ecs"
  description = "Allow user to manage ECS resources."
  policy      = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_user_policy_attachment" "ecs" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.ecs.arn
}

#########################
# Policy for IAM access #
#########################

data "aws_iam_policy_document" "iam" {
  statement {
    effect = "Allow"
    actions = [
      "iam:ListInstanceProfilesForRole",
      "iam:ListAttachedRolePolicies",
      "iam:DeleteRole",
      "iam:ListPolicyVersions",
      "iam:DeletePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetRole",
      "iam:GetPolicyVersion",
      "iam:GetPolicy",
      "iam:CreateRole",
      "iam:CreatePolicy",
      "iam:AttachRolePolicy",
      "iam:TagRole",
      "iam:TagPolicy",
      "iam:PassRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteServiceLinkedRole",
      "iam:GetServiceLinkedRoleDeletionStatus"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam" {
  name        = "${aws_iam_user.cd.name}-iam"
  description = "Allow user to manage IAM resources."
  policy      = data.aws_iam_policy_document.iam.json
}

resource "aws_iam_user_policy_attachment" "iam" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.iam.arn
}

################################
# Policy for CloudWatch access #
################################

data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    actions = [
      # Log group management
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",

      # Tag management
      "logs:TagResource",
      "logs:UntagResource",
      "logs:ListTagsForResource",
      "logs:ListTagsLogGroup",

      # Log retention
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",

      # Log stream operations
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:DeleteLogStream",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "logs" {
  name        = "${aws_iam_user.cd.name}-logs"
  description = "Allow user to manage CloudWatch resources."
  policy      = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_user_policy_attachment" "logs" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.logs.arn
}




data "aws_iam_policy_document" "elb" {
  statement {
    effect = "Allow"
    actions = [
      # Create/Delete Operations
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeleteListener",

      # Describe/Read Operations
      "elasticloadbalancing:Describe*", # This covers ALL Describe actions

      # Modify Operations
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:ModifyListener",

      # Listener Operations
      "elasticloadbalancing:SetListenerCertificates",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",

      # Security Group Operations
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",

      # Subnet Operations
      "elasticloadbalancing:SetSubnets",

      # IP Address Type
      "elasticloadbalancing:SetIpAddressType",

      # Tag Operations
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",

      # Rule Operations (for Listener Rules)
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:DescribeRules",

      # Target Operations
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "elb" {
  name        = "${aws_iam_user.cd.name}-elb"
  description = "Allow user to manage ELB resources."
  policy      = data.aws_iam_policy_document.elb.json
}

resource "aws_iam_user_policy_attachment" "elb" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.elb.arn
}



#########################
# Policy for EFS access #
#########################

data "aws_iam_policy_document" "efs" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DeleteFileSystem",
      "elasticfilesystem:DeleteAccessPoint",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DeleteMountTarget",
      "elasticfilesystem:DescribeMountTargetSecurityGroups",
      "elasticfilesystem:DescribeLifecycleConfiguration",
      "elasticfilesystem:CreateMountTarget",
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:CreateFileSystem",
      "elasticfilesystem:TagResource",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "efs" {
  name        = "${aws_iam_user.cd.name}-efs"
  description = "Allow user to manage EFS resources."
  policy      = data.aws_iam_policy_document.efs.json
}

resource "aws_iam_user_policy_attachment" "efs" {
  user       = aws_iam_user.cd.name
  policy_arn = aws_iam_policy.efs.arn
}