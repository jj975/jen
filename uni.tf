provider "aws" {
  region     = "eu-north-1"
  access_key = "AKIAQGL7X2SFB7VXYUGU"
  secret_key = "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"
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
  key    = "sourse"
  source = "./sourse"
}

resource "aws_s3_bucket_cors_configuration" "example_cors" {
  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = [file("url.txt")]
  }
}
