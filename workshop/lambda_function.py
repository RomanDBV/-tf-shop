import os
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):
    response = s3.get_object(
        Bucket=os.environ["BUCKET_NAME"],
        Key=os.environ["OBJECT_KEY"]
    )

    content = response["Body"].read().decode("utf-8")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/plain; charset=utf-8"
        },
        "body": content
    }
