# DHL Projekt
 **building a infrastructure with Terraform and AWS**

 **<p align="center" style="color:red; font-weight:bold">!-!-! Work in Progress !-!-!</p>**

Das Projekt, ist eine AWS-basierte Anwendung, die AWS Lambda und DynamoDB verwendet, um Paketinformationen zu verarbeiten. Hier ist eine kurze Zusammenfassung dessen, was jedes Element im Projekt macht:

1.  main.tf: Diese Datei ist eine Terraform-Konfigurationsdatei, die verwendet wird, um AWS-Ressourcen zu erstellen und zu verwalten. Sie definiert zwei AWS Lambda-Funktionen (get_driver und orderput), eine IAM-Rolle und -Richtlinie für die Lambda-Funktionen und eine DynamoDB-Tabelle namens Orders. Die Lambda-Funktionen verwenden Python 3.9 als Laufzeitumgebung.

2.  getdriver/index.py: Dies ist der Code für die get_driver Lambda-Funktion. Diese Funktion druckt einfach das empfangene Ereignis (in diesem Fall ein DynamoDB Stream-Ereignis) und gibt eine Erfolgsmeldung zurück.

3.  python/orderlambda.py: Dies ist der Code für die orderput Lambda-Funktion. Diese Funktion generiert zufällige Paketinformationen und fügt sie in die DynamoDB-Tabelle ein.

Insgesamt werden hier zufällige Paketinformationen in einer DynamoDB-Tabelle erzeugt und Änderungen an den Daten in der Tabelle über DynamoDB Streams verfolgt. Die get_driver-Funktion ist darauf ausgelegt, auf diese Stream-Ereignisse zu reagieren und sie zu protokollieren.

## Um das Projekt zu starten, 

müssen Sie Terraform verwenden, ein Open-Source-Infrastruktur-als-Code-Software-Tool, das eine sichere und effiziente Möglichkeit bietet, Infrastruktur zu erstellen, zu ändern und zu verbessern. Hier sind die Schritte, die Sie befolgen müssen:

1. Stellen Sie sicher, dass Sie Terraform auf Ihrem System installiert haben. Wenn nicht, können Sie es von der offiziellen Terraform-Website herunterladen und installieren.

*in der Datei: "terraform.tfvars" die eigene email adresse einfügen!*

2. Navigieren Sie im Terminal zu dem Verzeichnis, in dem sich Ihre `main.tf`-Datei befindet.

3. Laden Sie von der AWS seite und unter AWS Account auf "Command line or programmatic access" öffnen, dort die Shell auswählen mit der gearbeitet wird und die 1. Zeile kopieren um ihre Anmeldecredentials zu erhalten. Diese nun ins Terminal einfügen und somit ist ihr Terminal mit AWS verbunden.

4. Führen Sie den Befehl `terraform init` aus. Dieser Befehl initialisiert Ihr Terraform-Projekt und lädt die AWS-Provider-Plugins herunter.

5. Führen Sie den Befehl `terraform plan` aus. Dieser Befehl erstellt einen Ausführungsplan und zeigt Ihnen, welche Aktionen Terraform auf Ihrer Infrastruktur ausführen wird.

6. Wenn der Ausführungsplan korrekt aussieht, führen Sie den Befehl `terraform apply -var-file="terraform.tfvars`aus. Dieser Befehl wendet die Änderungen an und erstellt oder ändert Ihre Infrastruktur entsprechend der Konfiguration in Ihrer `main.tf`-Datei.
<!-- -var-file="terraform.tfvars der part muss immer bei apply mit angegeben werden sobald eine tfvars [für Variablen] verwendet werden solll! --> 
---

Bitte beachten Sie, dass Sie für die Ausführung dieser Befehle über ausreichende Berechtigungen in Ihrem AWS-Konto verfügen müssen. Stellen Sie außerdem sicher, dass Ihre AWS-Zugangsdaten korrekt konfiguriert sind, entweder durch Festlegen der Umgebungsvariablen AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY oder durch Konfigurieren des AWS CLI mit dem Befehl aws configure.

**Bitte beachten Sie auch, dass das Ausführen von terraform apply Kosten in Ihrem AWS-Konto verursachen kann, abhängig von den Ressourcen, die in Ihrer main.tf-Datei definiert sind.**
---

## Schritt für Schritt weiter in der Webconsole von AWS

### Erstellen der Fahrer

Die Fahrer werden durch den Code in der driver.py zufällig erstellt und erhalten die davor in der terraform.tfvars erstellten Email adresee für test zwecke.

1. Lambda in AWS öffnen (wir sehen dass von Terraform sämtliche Lambda Funktionen erstellt wurden).
2. Wir gehen in die "createdriver" Funktion und unten auf `Test`. Name des Test eingeben zb `creatdrivertest1` dann auf Speichern.
3. Nun den `Test Button` nochmal ausführen und wenn alles korrekt ist kommt die Meldung:  
Response
{
  "statusCode": 200,
  "body": "10 Dummy-Driverdatensätze erfolgreich eingefügt"
}
4. Wir kontrollieren die neu erstellten Fahrerdatensätze in DynamoDB. öffne einen neuen Tab mit dem Webbrowser und öffne in der Webkonsole von AWS `DynamoDB`. 
    -   links im Reiter Tabellen öffnen
    -   wir sehen die 2 von Terraform erstellten DynamoDB Tabellen wir öffnen `driver`.
    -   rechts oben `Tabellenelemente erkunden`öffnen.
    -   wenn wir runter scrollen sehen wir unter `Zurückgegebene Elemente` die erstellten fahrer.

### Versenden eines Packetes:

*Es gibt zwei möglichkeiten:*

1. [Random Packete erstellen lassen.
2. [Eingabe über ein Http Formular.

### 1. Variante auszuführen (Packete random erstellen lassen):

  1. in der Ordnerstruktur gibt es einen `testordner` in  dem die Datei `orderlambdazufällig.py` öffnen und den Inhalt kopieren und im Ordner `python`ind die Datei `orderlambda.py` einfügen.
    2. `terraform destroy`asuführen mit "yes" bstätigen.
    3. nun `terraform init, terraform plan und `terraform apply -var-file="terraform.tfvars"` erneut ausführen wieder mit "yes" bestätigen.
    
    4. Jetzt in AWS Webkonsole auf Lambda dort die `orderlambda` ausfwählen und auf Test drücken.
    Bei Testereignis konfigurieren einen Ereignis Namen vergeben zb.: `creatrandotmordertest1` und auf Speichern drücken.
    Nun Test erneut betätigen. Wenn alles passt erscheint folgende meldung:

      --Response
      {
        "statusCode": 200,
        "body": "Successfully inserted item with packageID FP16976300537459405"
      }--
    
    Kontrolle: wechsle in die DynamoDB Tabelle, wähle `Orders` und gehe rechts oben auf Tabellenelement erkunden:
    Wenn wir etwas runterscrollen sehen wir jetzt den ersten random eintrag in der Tabelle.

### 2. Variante Packet Versenden über ein Frontend Formular

  1.  wir Bauen das ganze wieder ab mit `terraform destroy`.
  2.  in der ordnerstruktur befindet sicher ordner `testordner` dari sind verschiedene test resource wir benoetigen den inhalt der `orderlambdatesthtmlinput.py` hier alles kopieren und im Ordner `python`ind die Datei `orderlambda.py` einfügen.
  3. nun `terraform init, terraform plan und `terraform apply -var-file="terraform.tfvars"` erneut ausführen wieder mit "yes" bestätigen.
  