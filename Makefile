AWS_BUCKET_TERRAFORM=tremligeiro-tc4-tf

tf-init:
	@cd tf \
		&& terraform init -backend-config="bucket=${AWS_BUCKET_TERRAFORM}"

tf-validate:
	@cd tf \
		&& terraform validate  

tf-plan:
	@cd tf \
		&& terraform plan
		
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