# Tests for cloudfront-function-terraform submodule

mock_provider "aws" {
  alias = "us-east-1"
}

mock_provider "aws" {}

# =================================================================
# CLOUDFRONT FUNCTION
# =================================================================

run "cloudfront_function_name_uses_variable" {
  command = plan
  variables {
    name = "StaticSiteReWriteDefaultIndexRequest"
  }
  module {
    source = "./cloudfront-function-terraform"
  }
  assert {
    condition     = aws_cloudfront_function.rewritedefaultindexrequest.name == "StaticSiteReWriteDefaultIndexRequest"
    error_message = "CloudFront function name must match var.name"
  }
}

run "cloudfront_function_runtime_is_js2" {
  command = plan
  variables {
    name = "StaticSiteReWriteDefaultIndexRequest"
  }
  module {
    source = "./cloudfront-function-terraform"
  }
  assert {
    condition     = aws_cloudfront_function.rewritedefaultindexrequest.runtime == "cloudfront-js-2.0"
    error_message = "CloudFront function must use cloudfront-js-2.0 runtime"
  }
}

run "cloudfront_function_is_published" {
  command = plan
  variables {
    name = "StaticSiteReWriteDefaultIndexRequest"
  }
  module {
    source = "./cloudfront-function-terraform"
  }
  assert {
    condition     = aws_cloudfront_function.rewritedefaultindexrequest.publish == true
    error_message = "CloudFront function must be published"
  }
}
