import boto3
import subprocess
import layer_sample


def handler(event, option):
    print("hello, lambda layers!")
    opt = (
        subprocess.run(["find", "/opt"], capture_output=True)
        .stdout.decode("utf-8")
        .split("\n")
    )
    return {"statusCode": 200, "body": layer_sample.hello(), "opt": opt}
