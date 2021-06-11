variable "name" {
  type        = string
  description = "The name of the application to deploy."
}

variable "handler" {
  type        = string
  description = "The entry point for the lambda."
  default     = "server/index.handler"
}

variable "runtime" {
  type        = string
  description = "The runtime for the lambda."
  default     = "nodejs12.x"
}

variable "timeout" {
  type        = number
  description = "The timeout for the lambda."
  default     = 10
}

variable "environment_variables" {
  type        = map(any)
  description = "The environment variables for the lambda."
  default     = {}
}

variable "domain_name" {
  type        = string
  description = "The URL to use for the lambda."
}

variable "zone_id" {
  type        = string
  description = "The zone id to create the url in."
}
