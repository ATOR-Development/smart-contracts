job "set-distribution-bonus-dev" {
  datacenters = ["ator-fin"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  task "set-distribution-bonus-dev-task" {
    driver = "docker"

    config {
      network_mode = "host"
      image = "ghcr.io/ator-development/smart-contracts:0.2.10"
      entrypoint = ["npx"]
      command = "ts-node"
      args = ["scripts/distribution/set-distribution-bonus.ts"]
    }

    vault {
      policies = ["distribution-dev"]
    }

    template {
      data = <<EOH
      {{with secret "kv/distribution/dev"}}
        DISTRIBUTION_OWNER_KEY="{{.Data.data.DISTRIBUTION_OWNER_KEY}}"
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
      DISTRIBUTION_BONUS="0"
      DISTRIBUTION_TIMESTAMP=""
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
