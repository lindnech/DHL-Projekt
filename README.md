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


