import logging
import boto3
import hello.test as m

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    # Write a log
    logger.info("This is an info log")
    logger.error("This is an error log")

    s3 = boto3.client("s3")
    s3.put_object(Bucket="robinsbucket", Key="hello.txt", Body=f"Hello {m.name}!")

    return {"statusCode": 200, "body": f"Hello, {m.name}, from Lambda!"}
