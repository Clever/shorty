# If you want to use outputs from a different terraform workspace, you
# can uncomment the following block and replace the bucket and key with
# the appropriate values. this is the preferred way to use values from
# terraform managed resources in other workspaces instead of hardcoding
# values.

# data "terraform_remote_state" "dev" {
#   backend = "s3"
#   config = {
#     bucket = "clever-terraform-state-dev"
#     key    = "state/file/key/terraform.tfstate"
#     region = "us-west-2"
#   }
# }
