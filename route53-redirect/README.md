# route53-redirect

This module creates a route53 alias record that points at a s3 static website bucket that redirects to another url.

## Usage

```hcl-terraform
resource route53_redirect {
  source       = "git@github.com:mestevens/terraform-modules.git//route53-redirect"
  domain       = "example.com"
  redirect_url = "http://google.ca"
  zone_id      = "YOURZONEID"
}
```
