# Usage

## Preparation
Create a S3 bucket for tfstate.
```sh
aws s3 mb s3://<Your own s3 bucket name>
```

Put your slack bot token in `terraform.tfvars.
```sh
SLACK_BOT_TOKEN=<your slack bot token>
cat <<-EOF
slack_bot_token = ${SLACK_BOT_TOKEN}
EOF > terraform.tfvars
```

## Deploy
```shell
make TF_S3_BUCKET=<Your own s3 bucket> apply
```

## Cleanup
```shell
make TF_S3_BUCKET=<Your own s3 bucket> destroy
```

## Refs
- https://slack.dev/python-slackclient/
