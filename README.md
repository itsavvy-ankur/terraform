# terraform
Terraform repository

# Execution Instuctions
* terraform plan
* terraform apply
* bash local-execs/init-vault
* source ~/VAULT-ENV.sh
* history | grep secret
* vault kv put secret/postgres_demo spring.datasource.username=***** spring.datasource.password=**** server.ssl.key-store-password=****
* kubectl create secret generic postgres-demo-secret --from-env-file=${HOME}/VAULT.env
* kubectl apply -f .
