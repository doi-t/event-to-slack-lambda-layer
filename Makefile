TF_S3_BUCKET:=
TF_BACKEND_KEY:=event-to-slack-lambda-layer/terraform.tfstate
TF_REGION:=ap-northeast-1

all: apply

.PHONY: init apply destroy clean

init:
	terraform init -backend=true \
		-backend-config="bucket=$(TF_S3_BUCKET)" \
		-backend-config="key=$(TF_BACKEND_KEY)" \
		-backend-config="region=$(TF_REGION)"

apply: init
	terraform apply

destroy: init
	terraform destroy

invoke:
	aws lambda invoke --function-name $$(terraform output -json | jq .lambda_function_name.value -r) output.json
	cat output.json | jq

clean:
	rm -rf packages
	rm -rf build
