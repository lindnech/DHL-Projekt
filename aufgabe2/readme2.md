# Aufgabe 2: DynamoDB Streams

1. Code von Thomas lesen und verstehen und deployen in der eigenen Sandbox

2. Dokumentation lesen zu DynamoDB Streams:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.html
https://www.youtube.com/watch?v=M0GJzjsw5So

3. Filter in Terraform hinzufügen: Nur neue Einträge in Terraform sollen die getdriver lambda triggern
Docs:
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.Lambda.Tutorial2.html

*Ab Zeile 42 Filter Beispiel:*
https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/master/examples/event-source-mapping/main.tf