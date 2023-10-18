provider "aws" { 
  region = "eu-central-1"  # Setzt die AWS-Region auf "eu-central-1"
}

# Zusammengefasst konfiguriert dieses Skript Terraform, um AWS-Ressourcen in der Region “eu-central-1” zu verwalten. 
# Ein Provider in Terraform ist verantwortlich für das Verständnis der API-Interaktionen und die Belichtung von Ressourcen. 
# Die Provider ermöglichen es Terraform, mit einer Vielzahl von Diensten zu interagieren.

############################# Lambda ##################################

# Definiert eine AWS Lambda-Funktion namens "request-lambda"
resource "aws_lambda_function" "request_lambda" {
  # Der Name der Lambda-Funktion
  function_name = "request-lambda"
  # Die IAM-Rolle, die der Lambda-Funktion zugewiesen wird
  role          = aws_iam_role.lambda_exec_role.arn
  # Der Handler für die Lambda-Funktion
  handler       = "request.lambda_handler"
  # Die Laufzeitumgebung für die Lambda-Funktion
  runtime       = "python3.9"
  # Der Pfad zur ZIP-Datei, die den Code der Lambda-Funktion enthält
  filename = "./python/request.zip"
  # Umgebungsvariablen für die Lambda-Funktion
  environment {
    variables = {
      # Die URL der SQS-Warteschlange, die als Umgebungsvariable bereitgestellt wird
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.id
      SNS_TOPIC_ARN = aws_sns_topic.example.arn
    
    }
  }
}

# Definiert eine AWS Lambda-Funktion namens "sns-lambda"
resource "aws_lambda_function" "sns" {
  # Der Name der Lambda-Funktion
  function_name = "sns-lambda"
  # Die IAM-Rolle, die der Lambda-Funktion zugewiesen wird
  role          = aws_iam_role.lambda_exec_role.arn
  # Der Handler für die Lambda-Funktion
  handler       = "sns.lambda_handler"
  # Die Laufzeitumgebung für die Lambda-Funktion
  runtime       = "python3.9"
  # Der Pfad zur ZIP-Datei, die den Code der Lambda-Funktion enthält
  filename = "./python/sns.zip"
  # Umgebungsvariablen für die Lambda-Funktion
  environment {
    variables = {
      # Die URL der SQS-Warteschlange, die als Umgebungsvariable bereitgestellt wird
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.id
      # Das ARN des SNS-Themas, das als Umgebungsvariable bereitgestellt wird
      SNS_TOPIC_ARN = aws_sns_topic.example.arn # das ARN des SNS-Themas, das als
    }
  }
}

# Zusammengefasst erstellt dieses Skript zwei AWS Lambda-Funktionen: request-lambda und sns-lambda. 
# Beide Funktionen verwenden Python 3.9 als Laufzeit und haben Zugriff auf eine SQS-Warteschlange 
# über eine Umgebungsvariable. Zusätzlich hat sns-lambda Zugriff auf ein SNS-Thema über eine Umgebungsvariable. 
# Der Code für jede Funktion befindet sich in einer ZIP-Datei im Verzeichnis ./python/.

#######################

# Definiert eine AWS Lambda-Funktion namens "getdriverlambda"
resource "aws_lambda_function" "get_driver" { # Der Name der Lambda-Funktion
  function_name = "getdriverlambda"  # Der Name der Lambda-Funktion
  role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Funktion zugewiesen wird
  handler       = "index.lambda_handler"  # Der Handler, der aufgerufen wird, wenn die Funktion ausgeführt wird
  runtime       = "python3.9"  # Die Laufzeitumgebung für die Funktion

  filename = "./getdriver/index.zip"  # Der Pfad zur ZIP-Datei, die den Code der Funktion enthält
}

resource "aws_lambda_event_source_mapping" "dynamodb_event_source" { # Definiert eine AWS Lambda Event Source Mapping-Ressource
  event_source_arn = aws_dynamodb_table.OrderDB.stream_arn  # Die ARN des DynamoDB-Streams, der als Ereignisquelle dient
  function_name = aws_lambda_function.get_driver.arn  # Die ARN der Lambda-Funktion, die aufgerufen wird, wenn ein Ereignis eintritt
  starting_position          = "LATEST"  # Der Punkt im Stream, an dem die Funktion zu lesen beginnt

  # Die Anzahl der Events, die gleichzeitig verarbeitet werden sollen
  batch_size = 1

# Filterkriterien für die Events
  filter_criteria {
    filter {
      # Das Muster für die zu filternden Events, in diesem Fall nur "INSERT"-Events
      pattern = jsonencode({
        eventName :["INSERT"]
        # body = {
        # }
      })
    }
  }
}

# Zusammengefasst erstellt dieses Skript eine AWS Lambda-Funktion namens getdriverlambda 
# und konfiguriert sie so, dass sie auf INSERT-Events in einem DynamoDB-Stream reagiert. 
# Der Code für die Funktion befindet sich in einer ZIP-Datei im Verzeichnis ./getdriver/. 
# Jedes Event wird einzeln verarbeitet (batch_size = 1).

#######################


# Definiert eine AWS Lambda-Funktion namens "orderlambda"
resource "aws_lambda_function" "orderput" {
  function_name = "orderlambda"  # Der Name der Lambda-Funktion
  role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Funktion zugewiesen wird
  handler       = "orderlambda.lambda_handler"  # Der Handler, der aufgerufen wird, wenn die Funktion ausgeführt wird
  runtime       = "python3.9"  # Die Laufzeitumgebung für die Funktion

  filename = "./python/orderlambda.zip"  # Der Pfad zur ZIP-Datei, die den Code der Funktion enthält

# Umgebungsvariablen für die Lambda-Funktion
  environment {
    variables = {
      # Der Name der DynamoDB-Tabelle, die als Umgebungsvariable
      DYNAMODB_TABLE = aws_dynamodb_table.OrderDB.name  # Eine Umgebungsvariable, die den Namen der DynamoDB-Tabelle enthält
      SQS_QUEUE_URL = aws_sqs_queue.order_queue.id  # Eine Umgebungsvariable, die die URL der SQS-Warteschlange enth】
    }
  }
}

# Definiert eine AWS Lambda-Funktion namens "createdriver"
resource "aws_lambda_function" "driverput" {
  # Der Name der Lambda-Funktion
  function_name = "createdriver"
  # Die IAM-Rolle, die der Lambda-Funktion zugewiesen wird
  role          = aws_iam_role.lambda_exec_role.arn
  # Der Handler für die Lambda-Funktion
  handler       = "driver.lambda_handler"
  # Die Laufzeitumgebung für die Lambda-Funktion
  runtime       = "python3.9"
  # Der Pfad zur ZIP-Datei, die den Code der Lambda-Funktion enthält
  filename = "./driver/driver.zip"
  # Umgebungsvariablen für die Lambda-Funktion
  environment {
    variables = {
      # Der Name der DynamoDB-Tabelle, die als Umgebungsvariable bereitgestellt wird
      DYNAMODB_TABLE = aws_dynamodb_table.OrderDB.name
      EMAIL = var.email_address
    }
  }
}

# Zusammengefasst erstellt dieses Skript zwei AWS Lambda-Funktionen: orderlambda und createdriver. 
# Beide Funktionen verwenden Python 3.9 als Laufzeit und haben Zugriff auf eine DynamoDB-Tabelle 
# über eine Umgebungsvariable. Der Code für jede Funktion befindet sich in einer ZIP-Datei in den 
# jeweiligen Verzeichnissen ./python/ und ./driver/.

#######################

# Erstellt eine IAM-Rolle für AWS Lambda
resource "aws_iam_role" "lambda_exec_role" {
  # Der Name der Rolle
  name = "lambda-exec-role"

  # Die Richtlinie, die festlegt, welche Dienste diese Rolle annehmen können
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Hängt eine IAM-Richtlinie an die erstellte Rolle an
resource "aws_iam_policy_attachment" "lambda_exec_policy" {
  # Der Name der Richtlinienanlage
  name = "Lambda-exec"
  
  # Die ARN der Richtlinie, die angehängt werden soll
  policy_arn = aws_iam_policy.lambda_policy.arn
  
  # Die Rollen, an die die Richtlinie angehängt werden soll
  roles      = [aws_iam_role.lambda_exec_role.name]
}

# Erstellt eine IAM-Richtlinie
resource "aws_iam_policy" "lambda_policy" {
  # Der Name der Richtlinie
  name = "lambda-policy"

  # Die Richtliniendetails
  policy = jsonencode({
    # Die Version der Richtlinie
    "Version": "2012-10-17",
    # Eine Liste von Aussagen in der Richtlinie
    "Statement": [
        {
            # Ein eindeutiger Bezeichner für die Aussage
            "Sid": "VisualEditor0",
            # Der Effekt der Aussage, hier erlaubt
            "Effect": "Allow",
            # Die Aktionen, die erlaubt sind
            "Action": [
                # Erlaubt alle Aktionen auf DynamoDB
                "dynamodb:*",
                # Erlaubt alle Aktionen auf SQS
                "sqs:*",
                # Erlaubt alle Aktionen auf SNS
                "sns:*"
            ],
            # Die Ressourcen, auf die sich die Aussage bezieht, hier alle Ressourcen
            "Resource": "*"
        },
        {
            # Ein eindeutiger Bezeichner für die Aussage
            "Sid": "VisualEditor1",
            # Der Effekt der Aussage, hier erlaubt
            "Effect": "Allow",
            # Die Aktionen, die erlaubt sind
            "Action": [
                # Erlaubt das Erstellen von Log-Streams
                "logs:CreateLogStream",
                # Erlaubt das Erstellen von Log-Gruppen
                "logs:CreateLogGroup",
                # Erlaubt das Hinzufügen von Log-Ereignissen zu einem Log-Stream
                "logs:PutLogEvents"
            ],
            # Die Ressourcen, auf die sich die Aussage bezieht, hier alle Log-Ressourcen
            "Resource": "arn:aws:logs:::*"
        }
    ]
})
}

# Dieser Terraform-Code erstellt eine AWS IAM-Rolle und eine IAM-Richtlinie und hängt die Richtlinie 
# an die Rolle an. Die Rolle wird so konfiguriert, dass sie von AWS Lambda-Diensten angenommen werden kann. 
# Die Richtlinie gibt den Lambda-Diensten Berechtigungen für verschiedene Aktionen, 
# einschließlich der Interaktion mit DynamoDB, SQS und SNS sowie der Erstellung und Aktualisierung 
# von Log-Streams und -Gruppen. Diese Konfiguration ist nützlich für die Bereitstellung von serverlosen 
# Anwendungen auf AWS mit Terraform.

############################ DynamoDB ############################
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
  name                      = "order-queue.fifo"  # Name der Warteschlange
  delay_seconds             = 0  # Verzögerungszeit für Nachrichten, die an die Warteschlange gesendet werden (in Sekunden)
  max_message_size          = 2048  # Maximale Größe einer Nachricht in der Warteschlange (in Bytes)
  message_retention_seconds = 86400  # Zeit, die eine Nachricht in der Warteschlange behalten wird, wenn sie nicht gelöscht wird (in Sekunden)
  visibility_timeout_seconds = 30  # Zeit, die eine Nachricht aus der Warteschlange unsichtbar ist, nachdem ein Empfänger eine Nachricht empfangen hat (in Sekunden)
  fifo_queue                = true # Ändern Sie auf true für FIFO-Warteschlange
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

# Eine Variable erstellen die eine Email adresse einfügt die nicht öffentlich sichtbar ist.
variable "email_address" {
  description = "Die E-Mail-Adresse, die verwendet werden soll"
  type = string
}


# Erstellen eines Abonnements für das SNS-Thema
resource "aws_sns_topic_subscription" "email_subscription" { # Dies definiert eine Ressource vom Typ aws_sns_topic_subscription mit dem Namen email_subscription.
  topic_arn = aws_sns_topic.example.arn  # ARN des SNS-Themas
  protocol  = "email"  # Protokoll für das Abonnement (in diesem Fall E-Mail)
  endpoint  = "${var.email_address}"  # Endpunkt für das Abonnement (in diesem Fall eine E-Mail-Adresse)
}

# Ausgabe der ARN des SNS-Themas
output "sns_topic_arn" { # Definiert eine Ausgabe mit dem Namen sns_topic_arn.
  value = aws_sns_topic.example.arn  # Setzt den Wert der Ausgabe auf den ARN des zuvor erstellten SNS-Themas.
}

# Dieser Terraform-Code erstellt ein Amazon Simple Notification Service (SNS) Thema und ein E-Mail-Abonnement für dieses Thema. 
# Das Thema heißt “example-topic”. Das Abonnement sendet Benachrichtigungen an die E-Mail-Adresse “emailadresse einfügen”. 
# Am Ende gibt der Code die Amazon Resource Number (ARN) des erstellten Themas aus.

####################### HTTP API Gateway und die Lambda dafür ########################

# Erstellt eine Lambda-Funktion mit der Ressource "aws_lambda_function"
# resource "aws_lambda_function" "example" {
#   function_name = "example_lambda"  # Der Name der Lambda-Funktion
#   handler       = "apilambda.lambda_handler"  # Der Handler der Lambda-Funktion
#   runtime       = "python3.9"  # Die Laufzeitumgebung für die Lambda-Funktion

#   filename = "./api/apilambda.zip"  # Der Pfad zur ZIP-Datei, die den Code der Lambda-Funktion enthält

#   role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Lambda-Funktion zugewiesen wird
# }

# Erstellt eine API Gateway mit der Ressource "aws_apigatewayv2_api"
resource "aws_apigatewayv2_api" "example" {
  name          = "API-Gateway-Input"  # Der Name der API Gateway
  protocol_type = "HTTP" # Der Protokolltyp der API Gateway
  cors_configuration {
    allow_origins = ["http://*"]
    allow_methods = ["POST", "GET", "DELETE", "*"]
    allow_headers = ["content-type"]
    max_age = 300
  }
}

# Erstellt eine Route für die API Gateway mit der Ressource "aws_apigatewayv2_route"
resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.example.id  # Die ID der API Gateway, zu der die Route gehört
  route_key = "PUT /orderlambda"  # Der Schlüssel der Route (Methode und Pfad)
  target    = "integrations/${aws_apigatewayv2_integration.example.id}"  # Das Ziel der Route (in diesem Fall eine Integration)
}

# Erstellt eine Integration zwischen der API Gateway und der Lambda-Funktion mit der Ressource "aws_apigatewayv2_integration"
resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.example.id  # Die ID der API Gateway, zu der die Integration gehört
  integration_type = "AWS_PROXY"  # Der Typ der Integration

  connection_type      = "INTERNET"  # Der Verbindungstyp der Integration
  description          = "Lambda integration"  # Die Beschreibung der Integration
  integration_method   = "POST"  # Die Methode, die für die Integration verwendet wird
  integration_uri      = aws_lambda_function.orderput.invoke_arn  # Die URI, die aufgerufen wird, wenn die Integration ausgelöst wird
}

# Erstellt eine Stufe für die API Gateway mit der Ressource "aws_apigatewayv2_stage"
resource "aws_apigatewayv2_stage" "example" {
  api_id      = aws_apigatewayv2_api.example.id  # Die ID der API Gateway, zu der die Stufe gehört
  name        = "$default"  # Der Name der Stufe
  auto_deploy = true  # Gibt an, ob Änderungen an dieser Stufe automatisch bereitgestellt werden sollen
}

# Erstellung eines HTTP API-Gateway mit Lambda integration: in eu-central-1 Lamda-Funktion?...., Version 2.0 und API-Name: API-Gateway-Input, 
# und einer Routen konfiguration: Methode: put?, Ressourcenpfad:?, Integrationsziel:? (Lambda für die API), Stufen konfiguration: Stufenname: $default,

# Erstellt eine Berechtigung für die Lambda-Funktion
resource "aws_lambda_permission" "apigw" {
  # Eindeutige ID für die Berechtigungserklärung
  statement_id  = "AllowExecutionFromAPIGateway"
  
  # Die Aktion, die die API Gateway auf die Lambda-Funktion ausführen darf
  action        = "lambda:InvokeFunction"
  
  # Der Name der Lambda-Funktion, auf die sich die Berechtigung bezieht
  function_name = aws_lambda_function.orderput.function_name
  
  # Der AWS-Service (in diesem Fall API Gateway), der die Berechtigung erhält
  principal     = "apigateway.amazonaws.com"

  # Die ARN der API Gateway, die die Berechtigung erhält, um die Lambda-Funktion auszulösen
  source_arn = "${aws_apigatewayv2_api.example.execution_arn}/*/*"
}

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

data "archive_file" "lambda6_code" { # Dieser Code ist ein Terraform-Skript, das eine Datenquelle vom Typ archive_file mit dem Namen lambda6_code definiert.
  type        = "zip"
  source_file = "./api/apilambda.py"  # Pfad zum ZIP-Datei-Quelldatei
  output_path = "./api/apilambda.zip" # Pfad, wohin das ZIP-Archiv extrahiert werden soll
}
#####################################################################