variable "domain" {
  type        = string
  description = "The route 53 domain you want to redirect from."
}

variable "redirect_url" {
  type        = string
  description = "The url you want to redirect to."
}

variable "zone_id" {
  type        = string
  description = "The hosted zone id for the aws route53 record."
}
