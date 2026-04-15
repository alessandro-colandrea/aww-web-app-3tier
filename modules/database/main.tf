resource "aws_db_subnet_group" "main" {         #Il gruppo di subnet per il database
  name       = "mio-db-subnet-group"
  subnet_ids = var.priv_subnet_ids 
  tags = { Name = "My DB subnet group" }
}


resource "aws_security_group" "db_sg" {
  name        = "db_security_group"
  vpc_id      = var.vpc_id #in che vpc operare

  ingress {
    from_port       = 3306 # Porta standard MySQL
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = var.app_subnet_cidrs #Solo i servizi nelle istanze private possono accedere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#specifichiamo i settings del database
resource "aws_db_instance" "default" {   
  allocated_storage    = 10              # 10 GB 
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"   
  
  username  = var.db_user
  password  = var.db_password
  db_name   = var.db_name
  
  parameter_group_name = "default.mysql8.0"
  
  #In che subnet stare e che sg usare 
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  # SICUREZZA E COSTI
  skip_final_snapshot    = true          #  evita costi extra quando fai destroy
  publicly_accessible    = false         # nessun accesso da internet 
  
  tags = {
    Name = "mio-db-interessi"
  }
}

