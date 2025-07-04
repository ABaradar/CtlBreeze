resource "nexus_repository_helm_proxy" "ceph" {
  depends_on   = [nexus_blobstore_file.helm]
  name         = "ceph"
  online       = true
  routing_rule = null

  http_client {
    auto_block = false
    blocked    = false

    connection {
      enable_circular_redirects = true
      enable_cookies            = false
      retries                   = 10
      timeout                   = 3600
      use_trust_store           = false
      user_agent_suffix         = null
    }
  }

  negative_cache {
    enabled = false
    ttl     = 0
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 14400
    remote_url       = "https://ceph.github.io/csi-charts"
  }

  storage {
    blob_store_name                = "helm"
    strict_content_type_validation = false
  }
}
resource "nexus_repository_helm_proxy" "coredns" {
  depends_on   = [nexus_blobstore_file.helm]
  name         = "coredns"
  online       = true
  routing_rule = null

  http_client {
    auto_block = false
    blocked    = false

    connection {
      enable_circular_redirects = true
      enable_cookies            = false
      retries                   = 10
      timeout                   = 3600
      use_trust_store           = false
      user_agent_suffix         = null
    }
  }

  negative_cache {
    enabled = false
    ttl     = 0
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 14400
    remote_url       = "https://coredns.github.io/helm"
  }

  storage {
    blob_store_name                = "helm"
    strict_content_type_validation = true
  }
}