#!/bin/bash
cd mgmt
terragrunt apply-all --terragrunt-non-interactive

cd ../hs
terragrunt apply-all --terragrunt-non-interactive