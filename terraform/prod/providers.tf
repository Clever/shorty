provider "aws" {
  allowed_account_ids = [module.shared_config.aws_accounts.prod.id]

  assume_role {
    role_arn = module.shared_config.aws_accounts.prod.roles.main.arn
  }
}
