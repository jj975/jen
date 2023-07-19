provider "aws" {
  region     = "eu-north-1"
  access_key = "AQGL7X2SFGWQ44CUF"
  secret_key = "pWWXN9uvkpz7t9cthHnHAxAhZM4Tm/HUvVU+FIZr"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "jj975novapomoyka"
  tags = {
    Name        = "My Terraform Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "terraform.sh"
  source = "./sourse/"
}
