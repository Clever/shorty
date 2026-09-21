terraform {
  backend "s3" {
    bucket       = "clever-terraform-state-infra-dev"
    key          = "shorty/terraform/dev/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = "true"
  }
}
