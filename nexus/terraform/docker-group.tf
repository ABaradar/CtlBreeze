resource "nexus_repository_docker_group" "docker-mirror" {
  depends_on = [
    nexus_repository_docker_proxy.dockerhub,
    nexus_repository_docker_proxy.gcr,
    nexus_repository_docker_proxy.ghcr,
    nexus_repository_docker_proxy.k8s,
    nexus_repository_docker_proxy.quay,
    nexus_repository_docker_proxy.mcr
  ]
  name   = "docker-mirror"
  online = true

  docker {
    force_basic_auth = false
    http_port        = 0
    https_port       = 0
    subdomain        = null
    v1_enabled       = true
  }

  group {
    member_names = [
      "mcr",
      "dockerhub",
      "gcr",
      "k8s",
      "quay",
      "ghcr"
    ]
    writable_member = null
  }

  storage {
    blob_store_name                = "docker-proxy"
    strict_content_type_validation = true
  }
}