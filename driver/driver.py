import boto3  # Importiert das boto3-Modul, das eine Python-Schnittstelle zu Amazon Web Services bietet.
import uuid  # Importiert das uuid-Modul, das Funktionen zur Erzeugung von eindeutigen Identifikatoren bereitstellt.

dynamodb = boto3.client('dynamodb')  # Erstellt einen Client für den Zugriff auf den Amazon DynamoDB-Service.

def lambda_handler(event, context):  # Definiert eine Funktion namens "lambda_handler" mit zwei Parametern: "event" und "context".
    table_name = "Drivers"  # Definiert den Namen der DynamoDB-Tabelle, in die die Daten eingefügt werden sollen.
    num_drivers = 10  # Definiert die Anzahl der Fahrerdatensätze, die erstellt werden sollen.

    for i in range(1, num_drivers + 1):  # Startet eine Schleife, die für jede Zahl von 1 bis num_drivers (einschließlich) ausgeführt wird.
        driver_id = str(uuid.uuid4())  # Erzeugt eine eindeutige ID für den Fahrer mit der Funktion uuid.uuid4 und konvertiert sie in einen String.
        driver_name = f"Driver-{i}"  # Erzeugt einen Fahrernamen, der aus dem String "Driver-" und der aktuellen Zahl i besteht.
        availability = "verfügbar"  # Setzt die Verfügbarkeit des Fahrers auf "verfügbar".

        item = {  # Erstellt ein Wörterbuch, das die Daten des Fahrers enthält.
            "driverID": {"S": driver_id},  # Fügt die Fahrer-ID als String hinzu.
            "Name": {"S": driver_name},  # Fügt den Fahrernamen als String hinzu.
            "Verfügbarkeit": {"S": availability},  # Fügt die Verfügbarkeit als String hinzu.
            "Email": {"S": "emailadresse"}  # Fügt eine Dummy-E-Mail-Adresse als String hinzu.
        }

        try:  # Startet einen Try-Block, um Fehler beim Einfügen des Datensatzes in die DynamoDB-Tabelle abzufangen.
            dynamodb.put_item(  # Ruft die Methode put_item des DynamoDB-Clients auf, um den Datensatz in die Tabelle einzufügen.
                TableName=table_name,
                Item=item
            )
            print(f"Driver {driver_name} erfolgreich in die Tabelle {table_name} eingefügt")  # Druckt eine Erfolgsmeldung, wenn das Einfügen erfolgreich war.
        except Exception as e:  # Fangt alle Ausnahmen ab, die beim Aufruf von put_item auftreten können.
            print(f"Fehler beim Einfügen des Drivers {driver_name} in die Tabelle {table_name}: {str(e)}")  # Druckt eine Fehlermeldung, wenn ein Fehler aufgetreten ist.

    return {  # Gibt ein Wörterbuch zurück, das einen HTTP-Statuscode und eine Nachricht enthält. Dies ist typisch für AWS Lambda-Funktionen, die als HTTP-Handler fungieren.
        "statusCode": 200,
        "body": f"{num_drivers} Dummy-Driverdatensätze erfolgreich eingefügt"
    }

# Dieser Code erstellt eine AWS Lambda-Funktion, die Dummy-Datensätze für Fahrer in einer Amazon DynamoDB-Tabelle erstellt. 
# Für jeden Datensatz wird eine eindeutige ID erzeugt und zusammen mit einem generierten Namen, einer festen Verfügbarkeit
#  und einer Dummy-E-Mail-Adresse in die Tabelle eingefügt. Wenn alle Datensätze erfolgreich eingefügt wurden, 
# gibt die Funktion eine Erfolgsmeldung zurück. Wenn beim Einfügen eines Datensatzes ein Fehler auftritt, 
# wird eine Fehlermeldung ausgegeben. Die Anzahl der zu erstellenden Datensätze kann durch Ändern des Werts der 
# Variable num_drivers angepasst werden. Der Name der DynamoDB-Tabelle kann durch Ändern des Werts der Variable 
# table_name angepasst werden. Dieser Code nutzt das boto3-Modul von Python, um auf den DynamoDB-Service zuzugreifen 
# und Operationen darauf auszuführen. Es verwendet auch das uuid-Modul von Python, um eindeutige IDs für jeden 
# Datensatz zu erzeugen. Dieser Code ist typisch für Szenarien, in denen Dummy-Daten in einer Datenbank 
# benötigt werden, z.B. zum Testen oder zur Demonstration. Es kann leicht angepasst werden, um andere Arten von 
# Datensätzen oder andere Datenbanken zu verwenden. Es kann auch in eine größere Anwendung integriert werden, 
# die AWS Lambda-Funktionen verwendet, um auf Ereignisse zu reagieren oder Aufgaben auszuführen. 
# Es ist wichtig zu beachten, dass dieser Code nur ein Beispiel ist und in einer Produktionsumgebung wahrscheinlich 
# zusätzliche Funktionen und Fehlerbehandlungen benötigt werden würden. 
