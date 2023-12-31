import boto3  # Importieren des boto3-Moduls, das die Amazon Web Services (AWS) SDK für Python enthält.
import random  # Importieren des random-Moduls, das Funktionen zur Generierung von Zufallszahlen enthält.
import json  # Importieren des json-Moduls, das Funktionen zur Verarbeitung von JSON-Daten enthält.
import os  # Importieren des os-Moduls, das Funktionen zur Verwaltung von Systeminformationen enthält.

# Initialisieren des SQS-Clients
sqs = boto3.client('sqs')
# Initialisieren des DynamoDB-Clients
dynamodb = boto3.client('dynamodb')

sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')

# Definieren des Namens der SQS-Warteschlange und der DynamoDB-Tabelle
sqs_queue_url = os.environ["SQS_QUEUE_URL"]

dynamodb_table_name = 'Drivers'

def assign_package_to_driver(package_id):
    try:
        # Scannen der DynamoDB-Tabelle nach verfügbaren Fahrern
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

        # Extrahieren der Liste der verfügbaren Fahrer aus der Antwort
        available_drivers = response.get('Items', [])

        if available_drivers:
            # Auswahl eines zufälligen verfügbaren Fahrers
            selected_driver = random.choice(available_drivers)

            # Extrahieren der Fahrer-ID des ausgewählten Fahrers
            driver_id = selected_driver['driverID']['S']

            # Aktualisieren der Verfügbarkeit des ausgewählten Fahrers auf 'nicht verfügbar'
            dynamodb.update_item(
                TableName=dynamodb_table_name,
                Key={
                    'driverID': {'S': driver_id}
                },
                UpdateExpression='SET #availability = :unavailable, #packageID = :packageID',
                ExpressionAttributeNames={
                    '#availability': 'Verfügbarkeit',
                    '#packageID': 'packageID'  # Ersetzen Sie 'packageID' durch den tatsächlichen Attributnamen
                },
                ExpressionAttributeValues={
                    ':unavailable': {'S': 'nicht verfügbar'},
                    ':packageID': {'S': package_id}  # Aktualisieren Sie das Attribut packageID mit dem zugewiesenen Wert
                }
            )

            # Führen Sie hier die Paketzuteilung an den Fahrer durch
            # Zum Beispiel aktualisieren Sie den Paketeintrag in Ihrer Datenbank mit der zugewiesenen Fahrer-ID

            return driver_id
        else:
            return None
    except Exception as e:
        raise Exception(f'Fehler beim Zuweisen des Pakets: {str(e)}')

def lambda_handler(event, context):
    try:
        # Abfragen der SQS-Warteschlange nach Nachrichten
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
            recipient_name = body.get('recipient_name'),
            recipient_address = body.get('recipient_address'),
            recipient_phone =body.get('recipient_phone'),
            package_id = body.get('packageID')

            if package_id:
                # Zuweisen des Pakets an den ausgewählten Fahrer
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
                    # Sie können hier Ihre Logik zur Bestätigung der Zuweisung durchführen
                    # Zum Beispiel senden Sie eine Bestätigungsnachricht an eine andere SQS-Warteschlange
                    # oder aktualisieren Sie den Paketstatus in Ihrer Datenbank
                    # ...

                    # Löschen der verarbeiteten Nachricht aus der SQS-Warteschlange
                    receipt_handle = message['ReceiptHandle']
                    sqs.delete_message(QueueUrl=sqs_queue_url, ReceiptHandle=receipt_handle)

                    return {
                        'statusCode': 200,
                        'body': f'Paket {package_id} erfolgreich dem Fahrer {driver_id} zugewiesen.'
                    }
                else:
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
# Dieser Code ist ein AWS Lambda-Handler, der eine Nachricht von einer Amazon SQS-Warteschlange abruft, 
# die eine Paket-ID enthält. Der Handler weist das Paket einem verfügbaren Fahrer zu, indem er die Fahrer 
# aus einer Amazon DynamoDB-Tabelle abruft und einen zufälligen Fahrer auswählt. Der ausgewählte Fahrer wird 
# dann als “nicht verfügbar” markiert und die Paket-ID wird in seinem Datensatz gespeichert. Wenn kein Fahrer verfügbar 
# ist oder die SQS-Nachricht keine Paket-ID enthält, gibt der Handler 
# eine entsprechende Antwort zurück. Nach erfolgreicher Zuweisung wird die verarbeitete Nachricht aus der SQS-Warteschlange 
# gelöscht. Bei Fehlern während des Prozesses wird eine Fehlermeldung zurückgegeben.