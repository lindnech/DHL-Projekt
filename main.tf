provider "aws" {
  region = "eu-central-1"  # Setzt die AWS-Region auf "eu-central-1"
}

############################# Lambda ##################################

resource "aws_lambda_function" "get_driver" {
  function_name = "getdriverlambda"  # Der Name der Lambda-Funktion
  role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Funktion zugewiesen wird
  handler       = "index.lambda_handler"  # Der Handler, der aufgerufen wird, wenn die Funktion ausgeführt wird
  runtime       = "python3.9"  # Die Laufzeitumgebung für die Funktion

  filename = "./getdriver/index.zip"  # Der Pfad zur ZIP-Datei, die den Code der Funktion enthält
}

resource "aws_lambda_event_source_mapping" "dynamodb_event_source" {
  event_source_arn = aws_dynamodb_table.OrderDB.stream_arn  # Die ARN des DynamoDB-Streams, der als Ereignisquelle dient
  function_name = aws_lambda_function.get_driver.arn  # Die ARN der Lambda-Funktion, die aufgerufen wird, wenn ein Ereignis eintritt
  starting_position          = "LATEST"  # Der Punkt im Stream, an dem die Funktion zu lesen beginnt

  # Set batch_size to 1 to process each event individually
  batch_size = 1

  filter_criteria {
    filter {
      
      pattern = jsonencode({
        eventName :["INSERT"]
        # body = {
        # }
      })
    }
  }
}



resource "aws_lambda_function" "orderput" {
  function_name = "orderlambda"  # Der Name der Lambda-Funktion
  role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Funktion zugewiesen wird
  handler       = "orderlambda.lambda_handler"  # Der Handler, der aufgerufen wird, wenn die Funktion ausgeführt wird
  runtime       = "python3.9"  # Die Laufzeitumgebung für die Funktion

  filename = "./python/orderlambda.zip"  # Der Pfad zur ZIP-Datei, die den Code der Funktion enthält

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.OrderDB.name  # Eine Umgebungsvariable, die den Namen der DynamoDB-Tabelle enthält
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"  # Der Name der IAM-Rolle

  assume_role_policy = jsonencode({  
    Version = "2012-10-17",  # Die Version der Richtlinie
    Statement = [{  # Eine Liste von Aussagen, die die Richtlinie definieren
      Action = "sts:AssumeRole",  # Die Aktion, die erlaubt ist
      Effect = "Allow",  # Die Wirkung der Aussage, in diesem Fall "Allow", was bedeutet, dass die Aktion erlaubt ist
      Principal = {
        Service = "lambda.amazonaws.com"  # Der Dienst, der die Aktion ausführen darf
      }
    }]
  })  
}

resource "aws_iam_policy_attachment" "lambda_exec_policy" {
  name       = "Lambda-exec"  # Der Name der Richtlinienanlage
  policy_arn = aws_iam_policy.lambda_policy.arn  # Die ARN der Richtlinie, die angehängt wird
  roles      = [aws_iam_role.lambda_exec_role.name]  # Die Rollen, denen die Richtlinie angehängt wird
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"  # Der Name der Richtlinie

  policy = jsonencode({
    Version = "2012-10-17",  # Die Version der Richtlinie
    Statement = [{  
      Action   = ["dynamodb:*"],  # Die Aktionen, die erlaubt sind (in diesem Fall alle Aktionen auf DynamoDB)
      Effect   = "Allow",  # Die Wirkung der Aussage, in diesem Fall "Allow", was bedeutet, dass die Aktionen erlaubt sind
      Resource = "*"  # Die Ressourcen, auf die sich die Aussage bezieht (in diesem Fall alle Ressourcen)
    },
    {
    Action   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    Effect   = "Allow",
    Resource = "*"
    }
    
    ]
  })
}

# ############################ DynamoDB ############################
# 1.Table
resource "aws_dynamodb_table" "OrderDB" {
  name           = "Orders"  # Der Name der Tabelle
  
 hash_key       = "packageID"  # Der Hash-Schlüssel für die Tabelle
 read_capacity   =20  # Die Lese-Kapazitätseinheiten für die Tabelle
 write_capacity   =20  # Die Schreib-Kapazitätseinheiten für die Tabelle

 stream_view_type ="NEW_IMAGE"  # Der Stream-Ansichtstyp für die Tabelle
 stream_enabled   ="true"  # Gibt an, ob der Stream aktiviert ist oder nicht

 attribute {
   name="packageID"  # Der Name des Attributs
   type="S"  # Der Typ des Attributs (in diesem Fall ein String)
 }
}

# Dieser Code verwendet Terraform, um AWS-Ressourcen zu erstellen und zu verwalten. 
# Es definiert zwei AWS Lambda-Funktionen (getdriverlambda und orderlambda), eine 
# DynamoDB-Tabelle (Orders) und eine IAM-Rolle (lambda-exec-role) mit einer zugehörigen Richtlinie (lambda-policy).

# Die Lambda-Funktionen sind so konfiguriert, dass sie auf Ereignisse reagieren, 
# die von einem DynamoDB-Stream generiert werden (definiert durch das aws_lambda_event_source_mapping-Ressourcenobjekt).

# Die IAM-Rolle und -Richtlinie geben den Lambda-Funktionen die erforderlichen 
# Berechtigungen zum Lesen und Schreiben in DynamoDB und zum Erstellen und Schreiben von Loggruppen und -streams.

# Die DynamoDB-Tabelle ist so konfiguriert, dass sie einen Stream von Änderungen an den 
# Tabellendaten bereitstellt, auf die die Lambda-Funktionen reagieren können. Der Primärschlüssel der Tabelle ist packageID.

# 2.Table
resource "aws_dynamodb_table" "DriverDB" { # Dies definiert eine Ressource vom Typ aws_dynamodb_table mit dem Namen DriverDB
  name           = "Drivers" # Legt den Namen der DynamoDB-Tabelle auf Drivers fest.
  hash_key = "driverID" # Definiert driverID als den Hash-Schlüssel der Tabelle. Dies ist der primäre Schlüssel, der zum Speichern und Abrufen von Daten verwendet wird.
  read_capacity = 20 # Legt die Lese-Kapazitätseinheiten der Tabelle auf 20 fest. Dies bestimmt, wie viele gleichzeitige Lesevorgänge pro Sekunde die Tabelle verarbeiten kann.
  write_capacity = 20 # Legt die Schreib-Kapazitätseinheiten der Tabelle auf 20 fest. Dies bestimmt, wie viele gleichzeitige Schreibvorgänge pro Sekunde die Tabelle verarbeiten kann.


  attribute { # Beginn des Attributblocks, der die Attribute für die Tabelle definiert.
    name = "driverID" # Legt den Namen des Attributs auf driverID fest.
    type = "S" # Legt den Typ des Attributs auf S fest, was für String steht.
  } # Ende des Attributblocks
} # Ende des Ressourcenblocks

# Zusammengefasst erstellt dieses Skript eine AWS DynamoDB-Tabelle namens “Drivers” mit einem 
# String-Attribut namens “driverID” als Hash-Schlüssel. Die Tabelle hat eine Lese- und Schreibkapazität von 20 Einheiten.

############################ SQS ############################

# Erstellen einer AWS SQS-Warteschlange
resource "aws_sqs_queue" "order_queue" {
  name                      = "order-queue"  # Name der Warteschlange
  delay_seconds             = 0  # Verzögerungszeit für Nachrichten, die an die Warteschlange gesendet werden (in Sekunden)
  max_message_size          = 2048  # Maximale Größe einer Nachricht in der Warteschlange (in Bytes)
  message_retention_seconds = 86400  # Zeit, die eine Nachricht in der Warteschlange behalten wird, wenn sie nicht gelöscht wird (in Sekunden)
  visibility_timeout_seconds = 30  # Zeit, die eine Nachricht aus der Warteschlange unsichtbar ist, nachdem ein Empfänger eine Nachricht empfangen hat (in Sekunden)
  fifo_queue                = false # Ändern Sie auf true für FIFO-Warteschlange
}

# Ausgabe der URL der SQS-Warteschlange
output "sqs_queue_url" {
  value = aws_sqs_queue.order_queue.id  # Wert der URL der SQS-Warteschlange
}

# Dieser Terraform-Code erstellt eine Amazon Simple Queue Service (SQS) Warteschlange namens “order-queue”. Die Warteschlange hat keine Verzögerung 
# für eingehende Nachrichten, eine maximale Nachrichtengröße von 2048 Bytes, behält Nachrichten für bis zu 86400 Sekunden (1 Tag) und macht eine Nachricht 
# für 30 Sekunden unsichtbar, nachdem ein Empfänger sie empfangen hat. Die Warteschlange ist keine FIFO-Warteschlange. Am Ende gibt der Code die URL der erstellten 
# Warteschlange aus.

###########################SNS##################################

# Dieser Code ist ein Terraform-Skript, das eine AWS Simple Notification Service (SNS) 
# Topic erstellt und ein E-Mail-Abonnement dafür konfiguriert.

# Erstellen eines AWS SNS-Themas
resource "aws_sns_topic" "example" { # Dies definiert eine Ressource vom Typ aws_sns_topic mit dem Namen example.
  name = "example-topic"  # Legt den Namen des SNS-Themas auf example-topic fest.
}

# Erstellen eines Abonnements für das SNS-Thema
resource "aws_sns_topic_subscription" "email_subscription" { # Dies definiert eine Ressource vom Typ aws_sns_topic_subscription mit dem Namen email_subscription.
  topic_arn = aws_sns_topic.example.arn  # ARN des SNS-Themas
  protocol  = "email"  # Protokoll für das Abonnement (in diesem Fall E-Mail)
  endpoint  = "<emailadresse eingeben>"  # Endpunkt für das Abonnement (in diesem Fall eine E-Mail-Adresse)
}

# Ausgabe der ARN des SNS-Themas
output "sns_topic_arn" { # Definiert eine Ausgabe mit dem Namen sns_topic_arn.
  value = aws_sns_topic.example.arn  # Setzt den Wert der Ausgabe auf den ARN des zuvor erstellten SNS-Themas.
}

# Dieser Terraform-Code erstellt ein Amazon Simple Notification Service (SNS) Thema und ein E-Mail-Abonnement für dieses Thema. 
# Das Thema heißt “example-topic”. Das Abonnement sendet Benachrichtigungen an die E-Mail-Adresse “emailadresse einfügen”. 
# Am Ende gibt der Code die Amazon Resource Number (ARN) des erstellten Themas aus.

######################### auto zip ##############################

# Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda*_code definiert.

data "archive_file" "lambda1_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda1_code definiert.
  type        = "zip"
  source_file = "./python/orderlambda.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./python/orderlambda.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}

data "archive_file" "lambda2_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda2_code definiert.
  type        = "zip"
  source_file = "./getdriver/index.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./getdriver/index.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}

data "archive_file" "lambda3_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda3_code definiert.
  type        = "zip"
  source_file = "./driver/driver.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./driver/driver.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}

data "archive_file" "lambda4_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda4_code definiert.
  type        = "zip"
  source_file = "./python/request.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./python/request.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}

data "archive_file" "lambda5_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda5_code definiert.
  type        = "zip"
  source_file = "./python/sns.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./python/sns.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}