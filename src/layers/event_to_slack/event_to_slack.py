import json
import boto3
from slackclient import SlackClient


def send(channel_name, event):
    print("Here is the event:")
    print(json.dumps(event))

    ssm_parameter_name = "event-to-slack-bot-token"
    client = boto3.client("ssm")
    slack_token = client.get_parameter(Name=ssm_parameter_name, WithDecryption=True)[
        "Parameter"
    ]["Value"]

    sc = SlackClient(slack_token)
    channel_list = sc.api_call("channels.list", exclude_archived=1)["channels"]
    channel_id = next(
        (ch["id"] for ch in channel_list if ch["name"] == channel_name), None
    )

    if event.get("detail-type") == "ECS Container Instance State Change":
        title = f"{event.get('detail-type', 'N/A')}\nec2InstanceId: {event.get('detail').get('ec2InstanceId', 'N/A')}"

        if event.get("detail").get("status", "N/A") != "ACTIVE":
            color = "warning"
        else:
            color = "#36a64f"

    elif event.get("detail-type") == "ECS Task State Change":
        title = f"{event.get('detail-type', 'N/A')}\ngroup: {event.get('detail').get('group', 'N/A')}"

        if event.get("detail").get("lastStatus", "N/A") != "RUNNING":
            color = "warning"
        else:
            color = "#36a64f"

    response = sc.api_call(
        "chat.postMessage",
        channel=channel_id,
        icon_emoji=":robot_face:",
        attachments=[
            {
                "title": title,
                "color": color,
                "text": f"status: *{event.get('detail').get('status', 'N/A')}*, lastStatus: *{event.get('detail').get('lastStatus', 'N/A')}* (reason: {event.get('detail').get('reason', 'N/A')})",
            },
            {"color": "#36a64f", "text": "```" + json.dumps(event, indent=4) + "```"},
        ],
    )

    if response.get("ok"):
        print(f"Successfully sent a received event to Slack! (channel: {channel_name})")
    else:
        print(response["error"])
        sc.api_call(
            "chat.postMessage",
            channel=channel_id,
            icon_emoji=":no_good:",
            text=response["error"],
        )
