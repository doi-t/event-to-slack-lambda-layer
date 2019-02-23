import json
import boto3
import subprocess
import event_to_slack


def handler(event, option):
    if event["source"] != "aws.ecs":
        raise ValueError(
            "Function only supports input from events with a source type of: aws.ecs"
        )

    channel_name = "test"
    event_to_slack.send(channel_name, event)
