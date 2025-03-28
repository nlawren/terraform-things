# Links:
# Cloudflare: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
# Ruan Bekker's useful post: https://ruan.dev/blog/2022/02/20/create-dns-records-with-terraform-on-cloudflare

resource "cloudflare_dns_record" "host-dns" {
  zone_id = var.zone_id
  name    = "localhost"
  content = "127.0.0.1"
  type    = "A"
  proxied = false
  ttl     = 3600
}
