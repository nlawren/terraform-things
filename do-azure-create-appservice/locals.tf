locals {
  environments = {
    for env, enabled in {
      dev  = var.enable_dev
      prod = var.enable_prod
    }
    : env => enabled
    if enabled
  }
}
