output "links_table_name" {
  description = "Full name of the shorty Links DynamoDB table (dev)"
  value       = module.links_table["us-west-2"].table_name
}

output "links_table_arn" {
  description = "ARN of the shorty Links DynamoDB table (dev)"
  value       = module.links_table["us-west-2"].table_arn
}
