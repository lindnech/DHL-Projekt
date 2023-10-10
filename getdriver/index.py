import json  # Importiert das json-Modul, das Methoden zum Parsen von JSON-Strings und zum 
# Konvertieren von Python-Datenstrukturen in JSON-Strings bereitstellt.


## Variante 1:

# def lambda_handler(event, context):  # Definiert eine Funktion namens "lambda_handler" mit zwei Parametern: "event" und "context".
#     print("Received event:", json.dumps(event))  # Druckt die Zeichenkette "Received event:" und den 
#     # Inhalt des "event"-Parameters, der mit der Methode json.dumps in einen JSON-String umgewandelt wurde.
#     # Process the DynamoDB records as needed  
#     # Ein Kommentar, der darauf hinweist, dass an dieser Stelle 
#     # der Code zur Verarbeitung der DynamoDB-Datensätze eingefügt werden sollte.
#     return {"statusCode": 200, "body": "Processed records"}  # Gibt ein Wörterbuch zurück, das einen 
# HTTP-Statuscode und eine Nachricht enthält. Dies ist typisch für AWS Lambda-Funktionen, die als HTTP-Handler fungieren.

# In diesem Fall nimmt die Funktion lambda_handler ein Ereignis und einen Kontext 
# als Eingabe, druckt das Ereignis in das Log und gibt dann eine HTTP-Antwort zurück.

## Variante 2 von Aufgabe2:

def lambda_handler(event, context):  # Definiert eine Funktion namens "lambda_handler" mit zwei Parametern: "event" und "context".
    for record in event['Records']:  # Durchläuft alle Datensätze im 'Records'-Feld des 'event'-Parameters.
        if record['eventName'] == 'INSERT':  # Überprüft, ob das 'eventName'-Feld des aktuellen Datensatzes 'INSERT' ist.
            print("Neuer Eintrag hinzugefügt:", record['dynamodb']['NewImage'])  # Wenn ja, druckt es die Zeichenkette "Neuer Eintrag hinzugefügt:" und den Inhalt des 'NewImage'-Feldes des 'dynamodb'-Feldes des aktuellen Datensatzes.
    return {"statusCode": 200, "body": "Verarbeitete Datensätze"}  # Gibt ein Wörterbuch zurück, das einen HTTP-Statuscode und eine Nachricht enthält. Dies ist typisch für AWS Lambda-Funktionen, die als HTTP-Handler fungieren.


# In diesem Code wird die Lambda-Funktion nur dann eine Aktion ausführen 
# (in diesem Fall das Drucken der neuen Elementdaten), wenn ein neues Element 
# in die DynamoDB-Tabelle eingefügt wurde.