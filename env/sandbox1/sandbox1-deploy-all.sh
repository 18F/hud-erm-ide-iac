#!/bin/bash
cd hs
for d in ./*/ ; do (cd "$d" && terragrunt init); done
terragrunt apply-all --terragrunt-non-interactive

cd ../microservice
for d in ./*/ ; do (cd "$d" && terragrunt init); done
terragrunt apply-all --terragrunt-non-interactive

# cd hs
# terragrunt apply-all --terragrunt-non-interactive

# cd ../microservice
# terragrunt apply-all --terragrunt-non-interactive