resource "nexus_repository_docker_proxy" "dockerhub" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "dockerhub"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "HUB"
    index_url  = null
  }

  http_client {
    auto_block = false
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
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://registry-1.docker.io"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}


resource "nexus_repository_docker_proxy" "gcr" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "gcr"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = false
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "REGISTRY"
    index_url  = null
  }

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
    enabled = false
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://k8s.gcr.io"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}

resource "nexus_repository_docker_proxy" "ghcr" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "ghcr"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "REGISTRY"
    index_url  = null
  }

  http_client {
    auto_block = false
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
    enabled = false
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://ghcr.io"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}

resource "nexus_repository_docker_proxy" "k8s" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "k8s"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "REGISTRY"
    index_url  = null
  }

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
    enabled = false
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://registry.k8s.io"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}


resource "nexus_repository_docker_proxy" "quay" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "quay"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "REGISTRY"
    index_url  = null
  }

  http_client {
    auto_block = false
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
    enabled = false
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://quay.io"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}

resource "nexus_repository_docker_proxy" "mcr" {
  depends_on   = [nexus_blobstore_file.docker-proxy]
  name         = "mcr"
  online       = true
  routing_rule = null

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  docker_proxy {
    cache_foreign_layers = true
    foreign_layer_url_whitelist = [
      ".*",
    ]
    index_type = "REGISTRY"
    index_url  = null
  }

  http_client {
    auto_block = false
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
    enabled = false
    ttl     = 1440
  }

  proxy {
    content_max_age  = 14400
    metadata_max_age = 1440
    remote_url       = "https://mcr.microsoft.com"
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}