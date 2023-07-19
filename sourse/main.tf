provider "aws" {
    region = "eu-north-1"
    access_key = "AKIAQGL7X2SFCD722SG4"
    secret_key = "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"
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


resource "aws_instance" "EC2-Instance" {
  availability_zone = "eu-north-1a"
  count             = 2
  ami               = "ami-0989fb15ce71ba39e"
  instance_type     = "t3.micro"
  key_name          = "key"
  vpc_security_group_ids = [aws_security_group.tersec[count.index].id]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 10
    volume_type           = "standard"
    delete_on_termination = true
    tags                  = {
      Name = "root-disk"
    }
  }

  tags = {
    Name = "EC2-Instance"
  }
}

resource "aws_security_group" "tersec" {
  count       = 2
  name        = "tersec-${count.index}"
  description = "uff - 165 social credit"

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "Allow 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ping"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "elastic_ip" {
  count = 2
  instance = aws_instance.EC2-Instance[count.index].id
}

output "elastic_ips" {
  value = aws_eip.elastic_ip.*.public_ip
}