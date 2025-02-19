provider "cloudflare" {
  api_token = "<YOUR_API_TOKEN>"
}

variable "zone_id" {
  default = "<YOUR_ZONE_ID>"
}

variable "account_id" {
  default = "<YOUR_ACCOUNT_ID>"
}

variable "domain" {
  default = "<YOUR_DOMAIN>"
}
