# Values such as account IDs, team names, slack channels, common roles,
# etc. should be pulled from the shared config module and not hardcoded.
module "shared_config" {
  source = "git@github.com:clever/tf-modules.git//shared_config"
}

# shorty's datastore, replacing the Postgres/RDS backend (being ripped out).
module "links_table" {
  for_each = toset(["us-west-2"])

  source = "git@github.com:clever/tf-modules.git//db/dynamo_table"

  table_name  = "shorty-db-Links"
  environment = "production"
  application = "shorty"
  team        = "eng-deip"
  region      = each.value
  repo        = "github:shorty"

  hash_key = "slug"
  attributes = [
    { name = "slug", type = "S" },
  ]

  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true

  # writers unset: task-role IAM comes from the databases: block in launch/shorty.yml.

  sso_critical               = "false"
  disaster_recovery_critical = "false"
  sensitive_data             = "false"
}
