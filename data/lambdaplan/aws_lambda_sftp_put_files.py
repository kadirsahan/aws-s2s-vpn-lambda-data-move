import paramiko
import string
import boto3
import json

#s3 = boto3.client('s3', aws_access_key_id='xxxxxxxxxx', aws_secret_access_key='xxxxxxxx')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # sftp adressess
    host = "10.200.0.131"
    port = 2222
    transport = paramiko.Transport((host, port))
    #Create a Transport object
    
    client = boto3.client("secretsmanager")
    get_value = client.get_secret_value(SecretId="sftpserver-1G")
    get_values = get_value.get("SecretString")
    json_values = json.loads(get_values)
    print(json_values)
    print(json_values['username'])
    print(json_values['password'])
    
    
    # password = "demo"
    # username = "demo"
    password = json_values['username']
    username = json_values['password']
    transport.connect(username = username, password = password)
    #Connect to a Transport server
    
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    filename = event["Records"][0]["s3"]["object"]["key"]

    
    sftp = paramiko.SFTPClient.from_transport(transport)
    
    with sftp.open('/sftp/'+filename, 'wb', 32768) as f:
        s3.download_fileobj(bucket, filename, f)
 
    # with sftp.open('/sftp/tensorflow-q5.txt', 'wb', 32768) as f:
    #     s3.download_fileobj('clvrtpxprt-private-bucket', 'tensorflow-q5.txt', f)   
    
    sftp.close()
    transport.close()