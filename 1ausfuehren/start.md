# Ausführen des Codes

*Start mit:*

1. in der Datei: "terraform.tfvars" die eigene email adresse einfügen!

2. Terraform init
3. Terraform plan

wenn alles passt ohne fehlermeldung dann weiter mit

4. Terraform apply

5. **Achtung im Terminal unten steht die "sqs_queue_url" wie im screenshot ".\sqs_queue_url.png" diesen zeile kopieren.**

6. dann in AWS Managemant Console anmelden

7. gehe auf Lambda: wähle die Orderlambda und öffne diese:
8. unten im Register "Code" in Zeile 14 die sqs_queue_url einfügen und dann auf Deploy klicken um dann auf Testen.

jetzt können wir in aws management console unter: DynamoDB,Elemente erkunden, Orders: sehen dass es nun einträge gibt.

9. 