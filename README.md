# Usage

## Preparation
Create a S3 bucket for tfstate.
```
aws s3 mb s3://<Your own s3 bucket name>
```

## Deploy
```shell
make TF_S3_BUCKET=<Your own s3 bucket> apply
```

## Cleanup
```shell
make TF_S3_BUCKET=<Your own s3 bucket> destroy
```
