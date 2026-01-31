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
    effect    = "Allow"
    actions   = [
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
