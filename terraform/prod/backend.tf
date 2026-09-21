terraform {
  backend "s3" {
    bucket       = "clever-terraform-state-infra"
    key          = "shorty/terraform/prod/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = "true"
  }
}
