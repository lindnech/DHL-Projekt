provider "aws" {
  region = "eu-central-1"  # Setzt die AWS-Region auf "eu-central-1"
}

# ############################# Lambda ##################################

# resource "aws_lambda_function" "get_driver" {
#   function_name = "getdriverlambda"  # Der Name der Lambda-Funktion
#   role          = aws_iam_role.lambda_exec_role.arn  # Die IAM-Rolle, die der Funktion zugewiesen wird
#   handler       = "index.lambda_handler"  # Der Handler, der aufgerufen wird, wenn die Funktion ausgeführt wird
#   runtime       = "python3.9"  # Die Laufzeitumgebung für die Funktion

#   filename = "./getdriver/index.zip"  # Der Pfad zur ZIP-Datei, die den Code der Funktion enthält
# }

# resource "aws_lambda_event_source_mapping" "dynamodb_event_source" {
#   event_source_arn = aws_dynamodb_table.OrderDB.stream_arn  # Die ARN des DynamoDB-Streams, der als Ereignisquelle dient
#   function_name = aws_lambda_function.get_driver.arn  # Die ARN der Lambda-Funktion, die aufgerufen wird, wenn ein Ereignis eintritt
#   starting_position          = "LATEST"  # Der Punkt im Stream, an dem die Funktion zu lesen beginnt
# }
# +-
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

# # Dieser Code verwendet Terraform, um AWS-Ressourcen zu erstellen und zu verwalten. 
# # Es definiert zwei AWS Lambda-Funktionen (getdriverlambda und orderlambda), eine 
# # DynamoDB-Tabelle (Orders) und eine IAM-Rolle (lambda-exec-role) mit einer zugehörigen Richtlinie (lambda-policy).

# # Die Lambda-Funktionen sind so konfiguriert, dass sie auf Ereignisse reagieren, 
# # die von einem DynamoDB-Stream generiert werden (definiert durch das aws_lambda_event_source_mapping-Ressourcenobjekt).

# # Die IAM-Rolle und -Richtlinie geben den Lambda-Funktionen die erforderlichen 
# # Berechtigungen zum Lesen und Schreiben in DynamoDB und zum Erstellen und Schreiben von Loggruppen und -streams.

# # Die DynamoDB-Tabelle ist so konfiguriert, dass sie einen Stream von Änderungen an den 
# # Tabellendaten bereitstellt, auf die die Lambda-Funktionen reagieren können. Der Primärschlüssel der Tabelle ist packageID.

# ############################ SQS ############################

# resource "aws_sqs_queue" "DHL-SQS-queue" {
#   name = "DHL-SQS-queue"
#   delay_seconds = 90
#   max_message_size = 2048
#   message_retention_seconds = 86400
#   receive_wait_time_seconds = 10
# }

