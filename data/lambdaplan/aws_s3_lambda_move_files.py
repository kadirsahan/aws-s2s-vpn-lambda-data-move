
import string
import boto3


s3 = boto3.client('s3')

def lambda_handler(event, context):

    # for each uploaded file, move them to private bucket
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        destination_bucket = 'clvrtpxprt-private-bucket'
        s3_key = record['s3']['object']['key']
        s3.copy_object(
            Bucket=destination_bucket
            , CopySource=f'{source_bucket}/{s3_key}'
            , Key=s3_key
        )
        s3.delete_object(Bucket=source_bucket, Key=s3_key)

