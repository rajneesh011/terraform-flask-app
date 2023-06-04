provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

resource "aws_security_group" "instance" {
  name_prefix = "instance-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "flask_app_key" {
  key_name   = "flask_app_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "flask_app_key"
}

resource "aws_instance" "ubuntu" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  user_data = "${file("fast.sh")}"
  tags = {
    Name = "Flask-Server"
  }
}


resource "aws_security_group" "rds" {
  name_prefix = "rds-"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_instance" "mysql" {
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  identifier             = "flask-db"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  port                   = var.port
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  tags = {
    Name = "mysql-instance"
  }
}

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "example-terraform-state"
#   acl    = "private"

#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "terraform-state-bucket"
#   }
# }

# resource "aws_s3_bucket_object" "terraform_state_backend" {
#   bucket = aws_s3_bucket.terraform_state.id
#   key    = "terraform.tfstate"
#   content = ""

#   tags = {
#     Name = "terraform-state-file"
#   }
# }
