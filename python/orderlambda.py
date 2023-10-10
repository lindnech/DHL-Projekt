import boto3  # Importiert das boto3-Modul, das eine Python-Schnittstelle zu Amazon Web Services bietet.
import random  # Importiert das random-Modul, das Funktionen zur Erzeugung von Zufallszahlen bietet.
import string  # Importiert das string-Modul, das eine Sammlung von String-Konstanten bereitstellt.
import time  # Importiert das time-Modul, das Funktionen zur Handhabung von Zeit bietet.
from datetime import date  # Importiert die date-Klasse aus dem datetime-Modul.

# Initialisiert die DynamoDB-Ressource
dynamodb = boto3.resource('dynamodb')  # Erstellt ein DynamoDB-Ressourcenobjekt mit boto3.
table = dynamodb.Table('Orders')  # Erstellt ein Tabellenobjekt für die angegebene Tabelle.

def random_string(length):
    """Erzeugt eine zufällige Zeichenkette fester Länge."""
    letters = string.ascii_letters + string.digits + " "  # Definiert die Menge der möglichen Zeichen.
    return ''.join(random.choice(letters) for i in range(length))  # Wählt zufällig Zeichen aus der definierten Menge und 
# fügt sie zu einer Zeichenkette zusammen.

def random_phone():
    """Erzeugt eine zufällige Telefonnummer."""
    return ''.join(random.choice(string.digits) for i in range(10))  # Wählt zufällig Ziffern aus und fügt sie 
# zu einer Zeichenkette zusammen.

def generate_packageID():
    """Erzeugt eine eindeutige Paket-ID."""
    timestamp = int(time.time() * 1000)  # Aktuelle Zeit in Millisekunden
    random_digits = ''.join(random.choice(string.digits) for i in range(4))  # Erzeugt eine zufällige vierstellige Zahl.
    return f"FP{timestamp}{random_digits}"  # Kombiniert die beiden vorherigen Elemente zu einer eindeutigen Paket-ID.

def lambda_handler(event, context):
    try:
        # Erstellt einen zufälligen Artikel
        item = {
            "recipient_name": random_string(10),  # Zufälliger Empfängername
            "recipient_address": random_string(25),  # Zufällige Empfängeradresse
            "recipient_phone": random_phone(),  # Zufällige Telefonnummer des Empfängers
            "sender_name": random_string(10),  # Zufälliger Absendername
            "sender_address": random_string(25),  # Zufällige Absenderadresse
            "sender_phone": random_phone(),  # Zufällige Telefonnummer des Absenders
            "dimensions_length": random.randint(1, 100),  # Zufällige Länge der Abmessungen
            "dimensions_width": random.randint(1, 100),  # Zufällige Breite der Abmessungen
            "dimensions_height": random.randint(1, 100),  # Zufällige Höhe der Abmessungen
            "weight": random.randint(1, 50),  # Zufälliges Gewicht
            "packageID": generate_packageID(),  # Generierte eindeutige Paket-ID
            "date": str(date.today()),  # Fügt das heutige Datum ein
            "insurance_type": random.choice(["Basic", "Premium", "Gold"]),  # Zufälliger Versicherungstyp
            "insurance_value": random.randint(1, 5000),  # Zufälliger Versicherungswert
            "restrictions": random.choice(["Sperrgut", "Zerbrechlich", "Liquid", "Flammable"]),  # Zwei zufällige Einschränkungen
            "value": random.randint(1, 1000)  # Zufälliger Wert
        }

        # Fügt den Artikel in die DynamoDB-Tabelle ein
        table.put_item(Item=item)  


        return {
            'statusCode': 200,
            'body': f'Successfully inserted item with packageID {item["packageID"]}'  
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error inserting item into DynamoDB: {str(e)}'  
        }

# Die Funktion lambda_handler erzeugt einen zufälligen Artikel mit verschiedenen Eigenschaften wie Empfängername, 
# Empfängeradresse usw. und fügt diesen Artikel dann in eine DynamoDB-Tabelle ein. Wenn der Artikel erfolgreich 
# eingefügt wurde, gibt die Funktion einen HTTP-Statuscode von 200 und eine Erfolgsmeldung zurück. 
# Wenn beim Einfügen des Artikels ein Fehler auftritt, gibt die Funktion einen HTTP-Statuscode von 500 und eine Fehlermeldung zurück.