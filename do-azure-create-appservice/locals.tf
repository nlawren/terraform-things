locals {
  active_environments = {
    for env, cfg in var.environments :
    env => cfg
    if cfg.enabled
  }
}
