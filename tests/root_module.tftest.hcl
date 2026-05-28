# Tests for root module

mock_provider "aws" {}

mock_provider "aws" {
  alias = "us-east-1"
}

variables {
  env_name                 = "test"
  aws_region               = "eu-west-2"
  cloudfront_function_name = "StaticSiteReWriteDefaultIndexRequest"
  platform_tags = {
    cost-centre = "12345"
    environment = "test"
  }
  cloud_front_default_vars = {}
  tenant_vars = {
    site1 = {
      repositories            = ["test-repo"]
      github_environment_name = "test"
      cost_centre             = "12345"
      account_code            = "5835"
      portfolio_id            = "cto"
      project_id              = "cc"
      service_id              = "cfm"
      product                 = "test-product"
      component               = "test-component"
      cloudfront_aliases      = ["test.example.com"]
      cloudfront_cert         = "arn:aws:acm:us-east-1:123456789012:certificate/test"
    }
  }
}

override_module {
  target = module.waf
  outputs = {
    waf_acl_arn  = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/test/test-id"
    waf_acl_name = "cc-static-site-test-acl"
  }
}

override_module {
  target = module.cloudfront
  outputs = {
    cloudfront_function_rewritedefaultindexrequest_arn = "arn:aws:cloudfront::123456789012:function/test"
  }
}

override_module {
  target = module.static_site["site1"]
  outputs = {
    s3_bucket_name                      = "test-bucket"
    cloudfront_distribution_domain_name = "test.cloudfront.net"
  }
}

run "waf_acl_name_uses_env_name" {
  command = plan
  assert {
    condition     = module.waf.waf_acl_name == "cc-static-site-test-acl"
    error_message = "WAF ACL name must be cc-static-site-{env_name}-acl"
  }
}

run "cloudfront_function_arn_not_empty" {
  command = plan
  assert {
    condition     = module.cloudfront.cloudfront_function_rewritedefaultindexrequest_arn != ""
    error_message = "CloudFront function ARN must not be empty"
  }
}