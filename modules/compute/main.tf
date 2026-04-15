#Launch template, modello di avvio per le istanze dell'auotscaling group
#Specifichiamo parametri hw, user data e identità Iam
resource "aws_launch_template" "web" {
  name_prefix = "web-template-"
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile {   #associamo istance profile per dare permessi alle istanze
    name = var.instance_profile_name
  }
  #usiamo userdata per iniettare i file de configurazione all'avvio
   user_data = base64encode(templatefile("${path.module}/setup.sh", {
   html_content   = file("${path.module}/templates/index.html")
   python_content = file("${path.module}/app.py")
   sql_content    = file("${path.module}/schema.sql")
   db_host     = var.db_host
   db_user     = var.db_user
   db_name     = var.db_name
   ssm_param_name="/prod/web-app/db-password"     #passo la pssw a setup.sh
   }))
   tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web-App-Python"
    }
  }
}
#creiamo l'autoscaling group per la gestione del parco istanze
resource "aws_autoscaling_group" "web_asg" {
  name                = "web-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.private_subnet_ids   #In che subnet?
  target_group_arns   = [var.target_group_arn]   #Dove devono andare le istanze create? tg lb
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Web-App-Python"
    propagate_at_launch = true
  }
}
#creiamo il security group per le istanze che accetta traffico in entrata solo dal load balancer
resource "aws_security_group" "web_sg" {
  name        = "allow_web_traffic"
  description = "Allow HTTP only from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP dal load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]      #Il traffico arriva dal sg dell'alb
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


