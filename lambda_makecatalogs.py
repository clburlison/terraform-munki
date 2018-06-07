from __future__ import print_function

import json
import os
import subprocess

DEBUG = False


def event_handler(event, context):
    """Run makecatalogs when a AWS event is sent."""
    if DEBUG:
        print("Received event: " + json.dumps(event, indent=2))

    os.environ["bucket_name"] = event["Records"][0]["s3"]["bucket"]["name"]
    all_env_vars = os.environ.copy()
    command = [
        "client/makecatalogs", "--repo_url", "s3Repo", "--plugin", "s3Repo"
    ]
    proc = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=all_env_vars,
    )

    while proc.poll() is None:
        print(proc.stdout.readline())
    print(proc.stdout.read())
