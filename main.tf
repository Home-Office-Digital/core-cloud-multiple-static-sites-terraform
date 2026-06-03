provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

module "waf" {
  source       = "git::https://github.com/Home-Office-Digital/core-cloud-static-sites-wafv2-terraform.git?ref=c48bb30eeafeb73c517f090eb91521f50c543f8a" # 0.4.11
  waf_acl_name = "cc-static-site-${var.env_name}-acl"
  tags         = var.platform_tags
  scope        = "CLOUDFRONT"
}

module "cloudfront" {
  name   = var.cloudfront_function_name
  source   = "./cloudfront-function-terraform/"
}

module "static_site" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-static-site-terraform.git?ref=00aa5ce59d4c654b988810a85c0deaa97a872a48" # 0.4.0

  for_each = var.tenant_vars

  cloudfront_function_rewrite_arn = module.cloudfront.cloudfront_function_rewritedefaultindexrequest_arn
  cloud_front_default_vars        = var.cloud_front_default_vars
  aws_region                      = var.aws_region
  tenant_vars                     = each.value
  waf_acl_id                      = module.waf.waf_acl_arn # cloudfront_distribution input variable waf_acl_id is actually the arn
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
}
