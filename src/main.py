import boto3
import subprocess


def handler(event, option):
    print("hello, world!")
    opt = (
        subprocess.run(["find", "/opt"], capture_output=True)
        .stdout.decode("utf-8")
        .split("\n")
    )
    return {"statusCode": 200, "body": "Hi!", "opt": opt}
