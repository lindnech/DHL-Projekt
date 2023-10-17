import boto3  
import time  
from datetime import date  
import json 

dynamodb = boto3.resource('dynamodb')  
table = dynamodb.Table('Orders')  

sqs = boto3.client('sqs')  

sqs_queue_url = 'aws_sqs_queue.order_queue.id'  

def lambda_handler(event, context):
    try:
        # Parse the JSON data from the event object
        data = json.loads(event['body'])

        item = {
            "recipient_name": data['recipient_name'],
            "recipient_address": data['recipient_address'],
            "recipient_phone": data['recipient_phone'],
            "sender_name": data['sender_name'],
            "sender_address": data['sender_address'],
            "sender_phone": data['sender_phone'],
            "dimensions_length": data['dimensions_length'],
            "dimensions_width": data['dimensions_width'],
            "dimensions_height": data['dimensions_height'],
            "weight": data['weight'],
            "packageID": data['packageID'],
            "date": str(date.today()),
            "insurance_type": data['insurance_type'],
            "insurance_value": data['insurance_value'],
            # Add the rest of your fields here...
        }

        table.put_item(Item=item)

        sqs_message = {
            "packageID": item["packageID"],  
            "message": "New package inserted into DynamoDB"  
        }

        sqs.set_queue_attributes(
            QueueUrl=sqs_queue_url,
            Attributes={
                'ContentBasedDeduplication': 'true'  # Aktiviert die inhaltsbasierte Entduplizierung
            }
        )

        sqs_response = sqs.send_message(
            QueueUrl=sqs_queue_url,
            MessageBody=json.dumps(sqs_message),  # Die zu sendende Nachricht
            MessageGroupId=item["packageID"]  # Die Gruppen-ID der Nachricht
        )

        return {
            'statusCode': 200,  # HTTP-Statuscode für Erfolg
            'body': f'Successfully inserted item with packageID {item["packageID"]}'  # Erfolgsmeldung
        }
    except Exception as e:
        return {
            'statusCode': 500,  # HTTP-Statuscode für internen Serverfehler
            'body': f'Error inserting item into DynamoDB: {str(e)}'  # Fehlermeldung
        }