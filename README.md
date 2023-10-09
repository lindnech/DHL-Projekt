# DHL Projekt
 building a infrastructure with Terraform and AWS

Das Projekt, ist eine AWS-basierte Anwendung, die AWS Lambda und DynamoDB verwendet, um Paketinformationen zu verarbeiten. Hier ist eine kurze Zusammenfassung dessen, was jedes Element im Projekt macht:

1.  main.tf: Diese Datei ist eine Terraform-Konfigurationsdatei, die verwendet wird, um AWS-Ressourcen zu erstellen und zu verwalten. Sie definiert zwei AWS Lambda-Funktionen (get_driver und orderput), eine IAM-Rolle und -Richtlinie für die Lambda-Funktionen und eine DynamoDB-Tabelle namens Orders. Die Lambda-Funktionen verwenden Python 3.9 als Laufzeitumgebung.

2.  getdriver/index.py: Dies ist der Code für die get_driver Lambda-Funktion. Diese Funktion druckt einfach das empfangene Ereignis (in diesem Fall ein DynamoDB Stream-Ereignis) und gibt eine Erfolgsmeldung zurück.

3.  python/orderlambda.py: Dies ist der Code für die orderput Lambda-Funktion. Diese Funktion generiert zufällige Paketinformationen und fügt sie in die DynamoDB-Tabelle ein.

Insgesamt werden hier zufällige Paketinformationen in einer DynamoDB-Tabelle erzeugt und Änderungen an den Daten in der Tabelle über DynamoDB Streams verfolgt. Die get_driver-Funktion ist darauf ausgelegt, auf diese Stream-Ereignisse zu reagieren und sie zu protokollieren.

Um das Projekt zu starten, müssen Sie Terraform verwenden, ein Open-Source-Infrastruktur-als-Code-Software-Tool, das eine sichere und effiziente Möglichkeit bietet, Infrastruktur zu erstellen, zu ändern und zu verbessern. Hier sind die Schritte, die Sie befolgen müssen:

1. Stellen Sie sicher, dass Sie Terraform auf Ihrem System installiert haben. Wenn nicht, können Sie es von der offiziellen Terraform-Website herunterladen und installieren.

2. Navigieren Sie im Terminal zu dem Verzeichnis, in dem sich Ihre `main.tf`-Datei befindet.

3. Führen Sie den Befehl `terraform init` aus. Dieser Befehl initialisiert Ihr Terraform-Projekt und lädt die AWS-Provider-Plugins herunter.

4. Führen Sie den Befehl `terraform plan` aus. Dieser Befehl erstellt einen Ausführungsplan und zeigt Ihnen, welche Aktionen Terraform auf Ihrer Infrastruktur ausführen wird.

5. Wenn der Ausführungsplan korrekt aussieht, führen Sie den Befehl `terraform apply` aus. Dieser Befehl wendet die Änderungen an und erstellt oder ändert Ihre Infrastruktur entsprechend der Konfiguration in Ihrer `main.tf`-Datei.

## Um das Projekt zu starten, 

müssen Sie Terraform verwenden, ein Open-Source-Infrastruktur-als-Code-Software-Tool, das eine sichere und effiziente Möglichkeit bietet, Infrastruktur zu erstellen, zu ändern und zu verbessern. Hier sind die Schritte, die Sie befolgen müssen:

Stellen Sie sicher, dass Sie Terraform auf Ihrem System installiert haben. Wenn nicht, können Sie es von der offiziellen Terraform-Website herunterladen und installieren.

Navigieren Sie im Terminal zu dem Verzeichnis, in dem sich Ihre main.tf-Datei befindet.

Verbinden Sie sich übers Terminal mit Ihren AWS Konto.

Führen Sie den Befehl ***terraform init*** aus. Dieser Befehl initialisiert Ihr Terraform-Projekt und lädt die AWS-Provider-Plugins herunter.

Führen Sie den Befehl ***terraform plan*** aus. Dieser Befehl erstellt einen Ausführungsplan und zeigt Ihnen, welche Aktionen Terraform auf Ihrer Infrastruktur ausführen wird.

Wenn der Ausführungsplan korrekt aussieht, führen Sie den Befehl ***terraform apply*** aus. Dieser Befehl wendet die Änderungen an und erstellt oder ändert Ihre Infrastruktur entsprechend der Konfiguration in Ihrer main.tf-Datei.

Bitte beachten Sie, dass Sie für die Ausführung dieser Befehle über ausreichende Berechtigungen in Ihrem AWS-Konto verfügen müssen. Stellen Sie außerdem sicher, dass Ihre AWS-Zugangsdaten korrekt konfiguriert sind, entweder durch Festlegen der Umgebungsvariablen AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY oder durch Konfigurieren des AWS CLI mit dem Befehl aws configure.

Bitte beachten Sie auch, dass das Ausführen von terraform apply Kosten in Ihrem AWS-Konto verursachen kann, abhängig von den Ressourcen, die in Ihrer main.tf-Datei definiert sind.


## Aufgabe 2 DynamoDB Streams

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
