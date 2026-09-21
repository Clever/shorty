# Values such as account IDs, team names, slack channels, common roles,
# etc. should be pulled from the shared config module and not hardcoded.
module "shared_config" {
  source = "git@github.com:clever/tf-modules.git//shared_config"
}
