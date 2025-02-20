provider "cloudflare" {
  api_token = "<YOUR_API_TOKEN>"
}

variable "zone_id" {
  default = "<YOUR_ZONE_ID>"
  type = string
}
