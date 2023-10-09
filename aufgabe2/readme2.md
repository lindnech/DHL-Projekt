# Aufgabe 2: DynamoDB Streams

1. Code von Thomas lesen und verstehen und deployen in der eigenen Sandbox

2. Dokumentation lesen zu DynamoDB Streams:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.html
https://www.youtube.com/watch?v=M0GJzjsw5So

3. Filter in Terraform hinzufügen: Nur neue Einträge in Terraform sollen die getdriver lambda triggern
Docs:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.Tutorial2.html

**Ab Zeile 42 Filter Beispiel:**
#### https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/master/examples/event-source-mapping/main.tf
---
### Info
#### DynamoDB Streams

*Filter in Terraform hinzufügen: Nur neue Einträge in Terraform sollen die getdriver lambda triggern.*

Um nur neue Einträge in der DynamoDB-Tabelle zu erfassen und die get_driver Lambda-Funktion auszulösen, können Sie die aws_dynamodb_event_source_mapping-Ressource in der main.tf-Datei anpassen.

Derzeit ist die starting_position auf "LATEST" gesetzt, was bedeutet, dass nur die neuesten Datenänderungen erfasst werden, die nach dem Aktivieren des Streams auftreten. Wenn Sie jedoch sicherstellen möchten, dass nur neue Einträge (und nicht Aktualisierungen oder Löschungen vorhandener Einträge) den Lambda-Trigger auslösen, müssen Sie einen Filter hinzufügen.

Leider bietet Terraform derzeit "Oktober2023" keine integrierte Möglichkeit, einen solchen Filter direkt in der aws_dynamodb_event_source_mapping-Ressource zu erstellen. Sie können jedoch eine bedingte Logik in Ihrer Lambda-Funktion implementieren, um nur auf neue Einträge zu reagieren.

In Ihrer get_driver Lambda-Funktion (in der index.py-Datei) können Sie überprüfen, ob das eventName des DynamoDB Stream-Ereignisses "INSERT" ist, was darauf hinweist, dass es sich um einen neuen Eintrag handelt. Hier ist ein Beispiel dafür, wie Sie das tun können:

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            print("New item added:", record['dynamodb']['NewImage'])
In diesem Code wird die Lambda-Funktion nur dann eine Aktion ausführen (in diesem Fall das Drucken der neuen Elementdaten), wenn ein neues Element in die DynamoDB-Tabelle eingefügt wurde.
