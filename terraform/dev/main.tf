# Values such as account IDs, team names, slack channels, common roles,
# etc. should be pulled from the shared config module and not hardcoded.
module "shared_config" {
  source = "git@github.com:clever/tf-modules.git//shared_config"
}

# Links table: shorty's only datastore, replacing the Postgres/RDS backend.
# Pure key-value — partition key `slug`, no range key, no GSIs (GetList is a
# full Scan). On-demand billing (module default PAY_PER_REQUEST). Single-region:
# shorty runs only in us-west-2. The for_each set is a single element today; add
# regions here if that ever changes.
#
# No TTL: the `expires` field exists in the data model but is dormant — the
# create route hardcodes "never", Postgres ignores it, and there's no UI to set
# it. If link expiry is ever revived, add ttl_enabled + ttl_attribute_name here.
module "links_table" {
  for_each = toset(["us-west-2"])

  source = "git@github.com:clever/tf-modules.git//db/dynamo_table"

  table_name  = "shorty-db-Links"
  environment = var.dev_environment
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

  # Pod access is granted on the k8s side via an inline iamPolicy.customPolicy
  # in config/shorty (matching who-is-who / district-dashboard-task-service),
  # not the module's writers/principal-tag policy, so `writers` is left unset.

  sso_critical               = "false"
  disaster_recovery_critical = "false"
  sensitive_data             = "false"
}
