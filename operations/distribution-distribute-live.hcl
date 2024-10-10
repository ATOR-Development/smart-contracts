job "distribution-distribute-live" {
  datacenters = ["ator-fin"]
  type = "batch"

  reschedule {
    attempts = 0
  }

  task "distribution-distribute-live-task" {
    driver = "docker"

    config {
      network_mode = "host"
      image = "ghcr.io/anyone-protocol/smart-contracts:0.3.7"
      entrypoint = ["npx"]
      command = "ts-node"
      args = ["scripts/distribution/distribute.ts"]
    }

    vault {
      policies = ["distribution-live"]
    }

    template {
      data = <<EOH
      {{with secret "kv/distribution/live"}}
        DISTRIBUTION_OPERATOR_KEY="{{.Data.data.DISTRIBUTION_OWNER_KEY}}"
        CONSUL_TOKEN="{{.Data.data.CONSUL_TOKEN}}"
      {{end}}
      EOH
      destination = "secrets/file.env"
      env         = true
    }

    env {
      PHASE="live"
      CONSUL_IP="127.0.0.1"
      CONSUL_PORT="8500"
      DISTRIBUTION_ADDRESS_CONSUL_KEY="smart-contracts/live/distribution-address"
      DISTRIBUTION_TIMESTAMP="<timestamp>"
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
