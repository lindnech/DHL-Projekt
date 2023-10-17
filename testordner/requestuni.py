import boto3
import random
import json
import os

# Initialize the SQS client
sqs = boto3.client('sqs')

# Initialize the SNS client
sns = boto3.client('sns')

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')


# Define the name of the SQS queue and DynamoDB table
sqs_queue_url = os.environ["SQS_QUEUE_URL"]
dynamodb_table_name = 'Drivers'

def assign_package_to_driver(package_id):
    try:
        # Scan the DynamoDB table for available drivers
        response = dynamodb.scan(
            TableName=dynamodb_table_name,
            FilterExpression='#availability = :available',
            ExpressionAttributeNames={
                '#availability': 'Verfügbarkeit'
            },
            ExpressionAttributeValues={
                ':available': {'S': 'verfügbar'}
            }
        )

        # Extract the list of available drivers from the response
        available_drivers = response.get('Items', [])

        if available_drivers:
            # Choose a random available driver
            selected_driver = random.choice(available_drivers)

            # Extract the driver ID of the selected driver
            driver_id = selected_driver['driverID']['S']

            # Update the availability of the selected driver to 'nicht verfügbar'
            dynamodb.update_item(
                TableName=dynamodb_table_name,
                Key={
                    'driverID': {'S': driver_id}
                },
                UpdateExpression='SET #availability = :unavailable, #packageID = :packageID',
                ExpressionAttributeNames={
                    '#availability': 'Verfügbarkeit',
                    '#packageID': 'packageID'  # Replace 'packageID' with the actual attribute name
                },
                ExpressionAttributeValues={
                    ':unavailable': {'S': 'nicht verfügbar'},
                    ':packageID': {'S': package_id}  # Update the packageID attribute with the assigned value
                }
            )

            # Perform the package assignment to the driver here
            # For example, update the package record in your database with the assigned driver ID

            return driver_id
        else:
            return None
    except Exception as e:
        raise Exception(f'Fehler beim Zuweisen des Pakets: {str(e)}')

def lambda_handler(event, context):
    try:
        # Query the SQS queue for messages
        response = sqs.receive_message(
            QueueUrl=sqs_queue_url,
            AttributeNames=['All'],
            MaxNumberOfMessages=1,
            MessageAttributeNames=['All'],
            VisibilityTimeout=30,
            WaitTimeSeconds=0
        )

        if 'Messages' in response:
            message = response['Messages'][0]
            body = json.loads(message['Body'])
            package_id = body.get('packageID')
            recipient_name = body.get('recipient_name'),
            recipient_address = body.get('recipient_address'),
            recipient_phone =body.get('recipient_phone'),
            restrictions = body.get('restrictions')

            if package_id:
                # Assign the package to the selected driver
                driver_id = assign_package_to_driver(package_id)

                if driver_id:
                    response = sns.publish(
                    TopicArn=sns_topic_arn,
                    Message=(f"""Hallo Fahrer {driver_id},
                             
                            das Paket {package_id} wurde an Sie zum Transport zugewiesen.

                            Details zum Auftrag:
                                Empfänger: {recipient_name}
                                Adresse: {recipient_address}
                                Telefonnummer: {recipient_phone}
                                Besonderheiten: {restrictions}
                             """)
                    )    
                    # Delete the processed message from the SQS queue
                    receipt_handle = message['ReceiptHandle']
                    sqs.delete_message(QueueUrl=sqs_queue_url, ReceiptHandle=receipt_handle)

                    return {
                        'statusCode': 200,
                        'body': f'Paket {package_id} erfolgreich dem Fahrer {driver_id} zugewiesen.'
                    }
                else:
                    # No available drivers found
                    return {
                        'statusCode': 200,
                        'body': 'Keine verfügbaren Fahrer gefunden.'
                    }
            else:
                return {
                    'statusCode': 400,
                    'body': 'Paket-ID fehlt in der SQS-Nachricht.'
                }
        else:
            return {
                'statusCode': 200,
                'body': 'Keine Nachrichten in der SQS-Warteschlange.'
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Fehler: {str(e)}'
        }