terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}