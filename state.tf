data "terraform_remote_state" "blog" {
  backend = "s3"

  config {
    bucket = "mrgossett-terraform-state"
    key    = "blog/terraform.tfstate"
    region = "us-east-1"
  }
}
