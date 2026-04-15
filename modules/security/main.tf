#Genera una chiave kms
resource "aws_kms_key" "parameter_key" {
  description = "Chiave per cifrare i segreti della web-app"
  deletion_window_in_days = 7  #tempo per eliminare la k
  enable_key_rotation = true  #rotazione della chiave
}

resource "aws_kms_alias" "parameter_key_alias" {  #diamo un alias alla chiave
  name = "alias/web-app-secrets"
  target_key_id = aws_kms_key.parameter_key.key_id
}

resource "aws_ssm_parameter" "db_password" {
  name = "/prod/web-app/db_password"
  type = "SecureString"
  value = var.db_password
  key_id=aws_kms_key.parameter_key.arn
}



resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ssm_read_policy" {
  name = "ssm-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 1. Permesso per leggere il segreto da SSM
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [aws_ssm_parameter.db_password.arn]
      },
      {
        # 2. Permesso per DECRIPTARE il segreto usando la chiave KMS
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        # Colleghiamo la policy alla chiave specifica che hai creato
        Resource = [aws_kms_key.parameter_key.arn]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_read_policy.arn
}

# Crea il "Profilo Istanza"
# Senza questo "gancio", le macchine non potrebbero autenticarsi 
resource "aws_iam_instance_profile" "ec2_profile" {       #passiamo il nome tramite output
  name = "ec2-instance-profile"                       
  role = aws_iam_role.ec2_role.name
}

