# Lab04-INCODE

# Iniciar sesión en AWS SSO
aws configure sso

terraform init -upgrade
terraform plan -var-file="ENTERNO PARA DESPLEGAR.tfvars"
terraform apply -var-file="ENTORNO PARA DESPLEGAR.tfvars" -auto-approve

#DESTRUIR infraestructura
terraform destroy -var-file="dev.tfvars" -auto-approve