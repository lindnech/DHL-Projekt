# Anforderung neuer Lieferflow bei DHL

Verarbeitung und Benachrichtigung von Nutzern über Paketzustellungsstatus bei DHL



1. Bestellungserstellung & -verarbeitung
    - Implementierung eines Systems, bei dem Kunden über eine App oder Website eine Bestellung erstellen können.
    - Anfrage wird an eine API-Schnittstelle gesendet.
    - Bestellung wird verarbeitet und in einer Datenbank gespeichert.

2. Fahrerzuweisung
    -  Automatische Zuweisung eines Fahrers nach Bestellungserstellung.
    - Nachricht wird an eine Warteschlange für Fahrerzuweisung gesendet.
    - Keine Bestellung geht verloren, unabhängig von Systemlast.

3. Benachrichtigung des Fahrers
    - Benachrichtigung des zugewiesenen Fahrers über eine neue Bestellung.
    - Eine Funktion ruft die Warteschlange für neue Bestellungen ab.
    - Bei Zuweisung wird der Fahrer benachrichtigt.

4. Aktualisierung des Lieferstatus
    - 4Fahrer können den Lieferstatus (z. B. "In Transit", "Delivered") aktualisieren.
    - Statusänderungen lösen Stream-Ereignisse aus.
    - Eine Funktion wird durch Stream-Ereignisse ausgelöst.

5. Kundenbenachrichtigung
    - Benachrichtigung des Kunden über den aktuellen Lieferstatus.
    - Eine Funktion überprüft den aktualisierten Status.
    - Bei Status "Delivered" wird der Kunde benachrichtigt.

6. Feedbacksammlung
    - Kunden können nach Erhalt der Lieferung Feedback geben.
    - Feedback wird über App oder Website an eine API-Schnittstelle gesendet.
    - Feedback wird verarbeitet und gespeichert.