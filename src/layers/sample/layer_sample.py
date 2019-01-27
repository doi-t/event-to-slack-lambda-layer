import boto3


def hello():
    print(boto3.client("sts").get_caller_identity())
    return "Hello! I'm sample lambda layer!"
