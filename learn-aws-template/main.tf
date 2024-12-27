resource "aws_vpc" "rfp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev.vpc"
  }
}

resource "aws_subnet" "rfp_public_subnet" {
  vpc_id                  = aws_vpc.rfp_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "dev.public_subnet"
  }
}

resource "aws_internet_gateway" "rfp_internet_gateway" {
  vpc_id = aws_vpc.rfp_vpc.id

  tags = {
    Name = "dev.igw"
  }
}

resource "aws_route_table" "rfp_public_rt" {
  vpc_id = aws_vpc.rfp_vpc.id

  tags = {
    Name = "dev.public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rfp_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rfp_internet_gateway.id
}

resource "aws_route_table_association" "rfp_public_rtassoc" {
  subnet_id      = aws_subnet.rfp_public_subnet.id
  route_table_id = aws_route_table.rfp_public_rt.id
}

resource "aws_security_group" "rfp_sg" {
  name        = "public_sg"
  description = "Public security group"
  vpc_id      = aws_vpc.rfp_vpc.id
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "rfp_auth" {
  key_name   = "rfpkey"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjh3LzSD8IWVSogLm8nSQelic9ZZlCLK9tO4JPuhx7w"
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.rfp_auth.id
  vpc_security_group_ids = [aws_security_group.rfp_sg.id]
  subnet_id              = aws_subnet.rfp_public_subnet.id
  user_data              = templatefile("userdata.tpl", {})

  tags = {
    Name = "dev_node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
    user = "ubuntu", })
    interpreter = ["bash", "-c"]
  }
}