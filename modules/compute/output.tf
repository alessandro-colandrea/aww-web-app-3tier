output "web_sg_id" {                       #serve al database per capire da chi ricevere 
  value = aws_security_group.web_sg.id
}

output "launch_template_id" {
  value = aws_launch_template.web.id
}