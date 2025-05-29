module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.9.0"

  bucket = "youurmentorsbucket"
}