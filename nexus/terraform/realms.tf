resource "nexus_security_realms" "realms" {
  active = [
    "NexusAuthenticatingRealm",
    "DockerToken"
  ]
}