############################################################
# API Gateway
############################################################

resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.name
}

resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.gateway_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.gateway_resource.id
  http_method             = aws_api_gateway_method.gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "live"
}

############################################################
# Lambda
############################################################

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*"
}

data "archive_file" "dummy" {
  type        = "zip"
  output_path = "${path.module}/lambda_code.zip"
  source {
    content  = "Upload your code."
    filename = "dummy.txt"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  role          = aws_iam_role.role.arn
  handler       = var.handler
  runtime       = var.runtime
  filename      = data.archive_file.dummy.output_path
  timeout       = var.timeout
  environment {
    variables = var.environment_variables
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

############################################################
# Custom Domain
############################################################

resource "aws_acm_certificate" "domain_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.domain_certificate.arn
}

resource "aws_api_gateway_domain_name" "gateway_domain" {
  certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn
  domain_name     = var.domain_name
}

resource "aws_route53_record" "domain_record" {
  name    = aws_api_gateway_domain_name.gateway_domain.domain_name
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.gateway_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.gateway_domain.cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.gateway_domain.domain_name
}
