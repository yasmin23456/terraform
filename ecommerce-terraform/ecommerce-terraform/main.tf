provider "aws" {
  region = "us-east-1" // تأكد من أن المنطقة صحيحة
}

resource "aws_instance" "backend" {
  ami           = "ami-0866a3c8686eaeeba" // AMI ID لـ CentOS 7
  instance_type = "t2.micro"              // 1 core, 1 GB RAM
  associate_public_ip_address = true

  root_block_device {
    volume_size = 64                      // 64 GB Disk
  }

  tags = {
    Name = "backend"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              EOF
}

resource "aws_instance" "frontend" {
  ami           = "ami-0866a3c8686eaeeba" // AMI ID لـ CentOS 7
  instance_type = "t2.micro"              // 1 core, 1 GB RAM
  associate_public_ip_address = true

  root_block_device {
    volume_size = 64                      // 64 GB Disk
  }

  tags = {
    Name = "frontend"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              EOF
}

resource "aws_db_subnet_group" "default" {
  name       = "my-subnet-group"
  subnet_ids = ["subnet-0efec9bb40b7d9540", "subnet-0ed3b9f10d9456f35"]
  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "password"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = "mysql-db"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow MySQL inbound traffic"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
