output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_pub_id" {
  value = aws_subnet.pubblica.id
}

output "subnet_priv1_id" {
  value = aws_subnet.privata.id
}

output "subnet_priv2_id" {
  value = aws_subnet.privata_2.id
}

output "priv_subnet_ids" {
  value = [aws_subnet.privata.id, aws_subnet.privata_2.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.pubblica.id, aws_subnet.pubblica_2.id]
}

output "priv_subnet_cidrs" {
  value = [aws_subnet.privata.cidr_block, aws_subnet.privata_2.cidr_block]
}