variable "domain_name" {
  type        = string
  description = "The URL to use for the website."
}

variable "zone_id" {
  type        = string
  description = "The zone id to create the url in."
}

variable "index_document" {
  type        = string
  description = "The file to serve up as the index."
  default     = "index.html"
}
