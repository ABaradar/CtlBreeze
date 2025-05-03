resource "nexus_repository_raw_proxy" "github" {
  depends_on   = [nexus_blobstore_file.github]
  name         = "github"
  online       = true
  routing_rule = null

  http_client {
    auto_block = true
    blocked    = false

    connection {
      enable_circular_redirects = false
      enable_cookies            = false
      retries                   = 0
      timeout                   = 0
      use_trust_store           = false
      user_agent_suffix         = ""
    }
  }

  negative_cache {
    enabled = true
    ttl     = 120
  }

  proxy {
    content_max_age  = -1
    metadata_max_age = 1440
    remote_url       = "https://github.com"
  }

  storage {
    blob_store_name                = "github"
    strict_content_type_validation = false
  }
}