job "distribution-toggle-family-multiplier-dev" {
  datacenters = ["ator-fin"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  task "distribution-toggle-family-multiplier-dev-task" {
    driver = "docker"

    config {
      network_mode = "host"
      image = "ghcr.io/anyone-protocol/smart-contracts:0.3.4"
      entrypoint = ["npx"]
      command = "ts-node"
      args = [
        "scripts/distribution/toggle-family-multiplier.ts"
      ]
    }

    vault {
      policies = ["distribution-dev"]
    }

    template {
      data = <<EOH
      {{with secret "kv/distribution/dev"}}
        DISTRIBUTION_OPERATOR_KEY="{{.Data.data.DISTRIBUTION_OWNER_KEY}}"
        CONSUL_TOKEN="{{.Data.data.CONSUL_TOKEN}}"
      {{end}}
      EOH
      destination = "secrets/file.env"
      env         = true
    }

    env {
      PHASE="dev"
      CONSUL_IP="127.0.0.1"
      CONSUL_PORT="8500"
      DISTRIBUTION_ADDRESS_CONSUL_KEY="smart-contracts/dev/distribution-address"
      FAMILY_MULTIPLIER_ENABLED="true"
    }

    restart {
      attempts = 0
      mode = "fail"
    }

    resources {
      cpu = 4096
      memory = 4096
    }
  }
}
