provider "aws" {
    region = "eu-north-1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

variable "users" {
    type    = list(string)
    default = ["db", "qp", "bob"]
}

resource "aws_iam_user" "teriam" {
    for_each = toset(var.users)
    name     = each.value
}

resource "random_password" "user_password" {
    for_each = aws_iam_user.teriam
    length   = 8
    special  = true
}


data "aws_iam_user" "current" {
    for_each   = toset(var.users)
    user_name  = aws_iam_user.teriam[each.value].name
}

resource "aws_iam_user_policy" "teriampol" {
    for_each = aws_iam_user.teriam
    name     = "teriampol-${each.key}"
    user     = each.value.name

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:Get*",
                "iam:List*",
                "iam:SimulateCustomPolicy",
                "iam:SimulatePrincipalPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

output "user_passwords" {
    value = {
        for user, password in random_password.user_password :
        user => password.result
    }
    sensitive = true
}


output "account_ids" {
    value = {
        for user, user_data in data.aws_iam_user.current :
        user => user_data.id
    }
}
