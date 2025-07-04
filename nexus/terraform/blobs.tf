resource "nexus_blobstore_file" "docker-proxy" {
  name = "docker-proxy"
  path = "docker-proxy"
  soft_quota {
    limit = 2147483648
    type  = "spaceUsedQuota"
  }
}

resource "nexus_blobstore_file" "github" {
  name = "github"
  path = "github"
  soft_quota {
    limit = 2147483648
    type  = "spaceUsedQuota"
  }
}

resource "nexus_blobstore_file" "helm" {
  name = "github"
  path = "github"
  soft_quota {
    limit = 2147483648
    type  = "spaceUsedQuota"
  }
}