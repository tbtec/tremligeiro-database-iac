tf-init:
	@cd tf \
		&& terraform init -reconfigure

tf-plan:
	@cd tf \
		&& terraform plan -var-file=config.tfvars

tf-delete:
	@cd tf \
		&& rm -r .terraform \
		&& rm .terraform.lock.hcl

tf-apply:
	@cd tf \
		&& terraform apply 

tf-destroy:
	@cd tf \
		&& terraform destroy -auto-approve