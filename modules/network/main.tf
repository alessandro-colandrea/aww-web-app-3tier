resource "aws_vpc" "main" {               #vpc
    cidr_block = var.vpc_cidr             #cidr block della vpc/24

    tags = {
        Name= "mia_vpc"
    }
}

resource "aws_subnet" "pubblica" {            #sub_pubblica_numero1
    vpc_id =aws_vpc.main.id                   #vpc in cui deve stare 
    cidr_block = var.subnet_pubb              #cidr della subnet/16
    map_public_ip_on_launch = true            #ogni istanza lanciata ricevera un ip pubblico
    availability_zone       = "${var.region}a"  #az in cui si trovera la subnet

    tags = {
        Name="mia_subnet_pubblica"
    }
}

resource "aws_subnet" "pubblica_2" {           #sub_pubblica_numero2
    vpc_id =aws_vpc.main.id
    cidr_block = var.subnet_pubb2
    map_public_ip_on_launch = true 
    availability_zone       = "${var.region}b"

    tags = {
        Name="mia_subnet_pubblica2"
    }
}

resource "aws_subnet" "privata" {              #sub_privata
    vpc_id =aws_vpc.main.id
    cidr_block = var.subnet_priv
    availability_zone = "${var.region}a"
    tags = {
        Name="mia_subnet_privata"
  }
}
resource "aws_subnet" "privata_2" {     #sub_privata_2
    cidr_block = var.subnet_priv2
    vpc_id = aws_vpc.main.id
    availability_zone = "${var.region}b" 

  tags = { 
       Name = "mia_subnet_privata_2" 
      }
}

resource "aws_internet_gateway" "main" {   #creiamo un igw per l'accesso ad internet
    vpc_id=aws_vpc.main.id

    tags = {
        Name= "sandro_igw"
    }
}

resource "aws_route_table" "public" {      #route_table_per_sub_pubblica
  vpc_id = aws_vpc.main.id
  tags   = { 
    Name = "public-rt" 
    }
}

resource "aws_route" "internet_access" {    #creiamo la rotta per l'accesso ad internet
  route_table_id         = aws_route_table.public.id        #in quale route table scriviamo questa regola
  destination_cidr_block = "0.0.0.0/0"                      #destinazione internet 
  gateway_id             = aws_internet_gateway.main.id     #indirizza verso igw il traffico
}

resource "aws_route_table_association" "public" {         #associazione_pubblica
  subnet_id      = aws_subnet.pubblica.id                 #Quale subnet deve seguire queste regole?
  route_table_id = aws_route_table.public.id              #la associamo alla route_table.public.id
}

resource "aws_eip" "nat_eip" {            #creiamo un elastic ip per il nat gateway
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {        #creiamo il nat gateway
  allocation_id = aws_eip.nat_eip.id      #colleghiamo l'eip al natgateway
  subnet_id     = aws_subnet.pubblica.id  # subnet pubblica

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {    #creiamo route table privata
  vpc_id = aws_vpc.main.id                   #in che vpc si trova

  route {
    cidr_block     = "0.0.0.0/0"             #tutto il traffico verso internet
    nat_gateway_id = aws_nat_gateway.nat.id  #passa tramite natgateway per andare su internet
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "priv1_assoc" {    #associamo la route table privata alla sub privata
  subnet_id      = aws_subnet.privata.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "priv2_assoc" {
  subnet_id      = aws_subnet.privata_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_2" {   #associamo la route table alla subnet_pubblica_2
  subnet_id      = aws_subnet.pubblica_2.id
  route_table_id = aws_route_table.public.id
}

