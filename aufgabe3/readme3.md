# DHL Kochbuch von Max aufgabe 3

1. SQS erstellen 

1. 1  Lambda Export Item in SQS Queue

2. Füllen DynamoDB (Table Fahrer) mit Dummy Fahrerwerten ( 10 Fahrer mit BSP daten, alle ini verfügbar)  

3. LAMBDA fragt Queue an4. Anfrage an DynamoDB (Table Fahrer) ob ein Fahrer verfügbar ist

5. LAMBDA passt DynamoDB (Table Fahrer) den Status des gewählten Fahrers an ( nicht verfügbar) 

6. LAMBDA passt DynamoDB (Table Fahrer) Lieferung und zwar mit Paket_ID  
7. LAMBDA Infos an SNS weiterreichen um EMAIL zu versenden Fahrer_Email, Paket_ID, DynamoDB Table ITEM Werte in formatierte Variante
