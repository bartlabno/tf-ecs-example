terraform {
  source = "../."
}

inputs = {
  owner       = "Bart Labno"
  environment = "dev"
  project     = "react"

  base_domain = "barts-simple.app"

  backend_version  = "latest"
  frontend_version = "latest"

  block_cidr = "10.30.0.0/16"
}

remote_state {
  backend = "s3"
  config = {
    bucket  = "simple-react-app-backend-bl"
    key     = "dev/react/services/react.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}