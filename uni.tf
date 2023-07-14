provider "aws" {
    region = "eu-north-1"
    access_key = "AKIAQGL7X2SFETNE3SZ6"
    secret_key = "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"
}

resource "aws_instance" "EC2-Instance"{
    availability_zone = "eu-north-1a"
    ami = "ami-0989fb15ce71ba39e"
    instance_type = "t3.micro"
    key_name = "key"
    vpc_security_group_ids =  [aws_security_group.tersec.id]

    ebs_block_device {
        device_name = "/dev/sda1"
        volume_size = 10
        volume_type = "standard"
        tags = {
        Name = "root-disk"
      }
    }
    user_data = file("install.sh")

    tags = {
        Name = "EC2-Instance-terraform-jenkins"
    }
}

resource "aws_security_group" "tersec" {
    name="tersec"
    description = "uff - 165 social credit"

    dynamic "ingress" {
      for_each = ["80", "443", "161", "10050", "10051", "3306", "3369", "55555", "4444", "333"]
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
      ingress {
        description = "Allow 22"
        from_port = 22
        to_port= 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow ping"
        from_port = 0
        to_port= 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }



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

resource "aws_s3_bucket" "my_bucket" {
  bucket = "jj975novapomoyka"

  tags = {
    Name        = "Справжня помойка"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "example_object_file" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "install.sh"
}


resource "aws_s3_bucket_cors_configuration" "example_cors" {
  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = [file("url.txt")]
  }
}




