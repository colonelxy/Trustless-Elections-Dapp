resource "aws_vpc" "terraform_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "terraform_public_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "dev_public"
  }
}

resource "aws_internet_gateway" "terraform_IGW" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "dev_IGW"
  }
}

resource "aws_route_table" "terraform_public_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    "Name" = "dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.terraform_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terraform_IGW.id
}

resource "aws_route_table_association" "terraform_public_rt_assoc" {
  subnet_id      = aws_subnet.terraform_public_subnet.id
  route_table_id = aws_route_table.terraform_public_rt.id
}

resource "aws_security_group" "terraform_SG" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "all"
    from_port = 0
    ipv6_cidr_blocks = [ ]
    protocol = "-1"
    security_groups = [ ]
    prefix_list_ids = []
    self = false
    to_port = 0
  } ]

  egress = [ {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "all"
    from_port = 0
    ipv6_cidr_blocks = [ ]
    protocol = "-1"
    security_groups = [ ]
    prefix_list_ids = []
    self = false
    to_port = 0
  } ]
}

resource "aws_key_pair" "tera_auth" {
  key_name = "terakey"
  public_key = file("~/.ssh/terakey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id
  key_name = aws_key_pair.tera_auth.id
  vpc_security_group_ids = [aws_security_group.terraform_SG.id]
  subnet_id = aws_subnet.terraform_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev_node"
  }  

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      IdentityFile = "~/.ssh/terakey"
    })

    interpreter = var.host_os == "windows" ? ["powershell", ".Command"] : ["bash", "-c"]
  
  }
  
}