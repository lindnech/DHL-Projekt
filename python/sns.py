import boto3  # Importieren des boto3-Moduls, das die Amazon Web Services (AWS) SDK für Python enthält.
import os  # Importieren des os-Moduls, das Funktionen zur Interaktion mit dem Betriebssystem enthält.

def lambda_handler(event, context):
    # Verbindung zu DynamoDB und SNS herstellen
    dynamodb = boto3.client('dynamodb')
    sns = boto3.client('sns')

    # Abrufen der SNS-Themen-ARN aus den Umgebungsvariablen
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')

    if sns_topic_arn is None:
        return {
            "statusCode": 500,
            "body": "SNS_TOPIC_ARN environment variable is not set."
        }

    # Den Namen der Zieltabelle für die Fahrer und Bestellungen festlegen
    driver_table_name = "Drivers"  # Ihr DynamoDB-Tabellenname für die Fahrer
    orders_table_name = "Orders"  # Ihr DynamoDB-Tabellenname für die Bestellungen

    # Alle Fahrer aus der "Fahrer"-Tabelle abrufen
    response = dynamodb.scan(TableName=driver_table_name)
    drivers = response.get('Items', [])

    for driver in drivers:
        # Den Fahrername und die E-Mail-Adresse aus der "Fahrer"-Tabelle abrufen
        driver_name = driver['Name']['S']
        driver_email = driver['Email']['S']

        # Die packageID des Fahrers aus der "Fahrer"-Tabelle abrufen
        package_id = driver.get('packageID', {}).get('S', 'N/A')

        # Informationen aus der "Orders"-Tabelle abrufen
        response = dynamodb.query(
            TableName=orders_table_name,
            KeyConditionExpression='packageID = :packageID',  # Verwenden Sie 'packageID' als Schlüsselattribut in Ihrer "Orders"-Tabelle
            ExpressionAttributeValues={
                ':packageID': {'S': package_id}
            }
        )

        # Prüfen, ob es Ergebnisse gibt (abhängig von Ihrer Datenbankstruktur)
        if 'Items' in response:
            order_data_list = response['Items']

            for order_data in order_data_list:
                # Informationen aus der Antwort extrahieren
                recipient_address = order_data.get('recipient_address', {}).get('S', 'N/A')

                # Nachricht erstellen
                message = f"Hallo {driver_name}, dein Paket hat die ID {package_id}. Das Paket soll an {recipient_address}. Weitere Infos #restrictions"

                # Nachricht an SNS senden (Hinweis: Sie müssen zuvor ein SNS-Thema erstellen und die ARN hier einsetzen)
                sns_topic_arn = sns_topic_arn ####hier bearbeiten####
                sns.publish(TopicArn=sns_topic_arn, Message=message)

    return {
        "statusCode": 200,
        "body": f"E-Mails wurden erfolgreich versendet. {driver_name} {driver_email}"
    }


# Dieser Code ist ein AWS Lambda-Handler, der alle Fahrer aus einer Amazon DynamoDB-Tabelle namens “Drivers” abruft. 
# Für jeden Fahrer wird die zugehörige Paket-ID abgerufen und dann wird eine Abfrage an eine andere DynamoDB-Tabelle 
# namens “Orders” gestellt, um Informationen über die Bestellung zu erhalten. Eine Nachricht wird erstellt, die den Namen 
# des Fahrers, die Paket-ID und die Adresse des Empfängers enthält. Diese Nachricht wird dann an ein Amazon SNS-Thema gesendet. 
# Wenn die Umgebungsvariable SNS_TOPIC_ARN nicht gesetzt ist, gibt der Handler eine Fehlermeldung zurück.