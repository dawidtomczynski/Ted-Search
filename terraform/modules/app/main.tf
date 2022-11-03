resource "aws_security_group" "dawid-ted" {
  name        = var.name
  description = "open http & ssh"
  vpc_id      = var.vpc_id
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  
    ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}

resource "aws_instance" "dawid-ted" {
  ami                         = var.ami 
  associate_public_ip_address = true
  instance_type               = var.instance_type
  availability_zone           = var.av_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.dawid-ted.id]

  connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file(var.private_key)
      host = self.public_dns  
      }

    provisioner "file" {
      source      = "../app/src/main/resources/static"
      destination = "/home/ubuntu/"
    }

    provisioner "file" {
      source      = "../nginx.conf"
      destination = "/home/ubuntu/nginx.conf"
    }

    provisioner "file" {
      source      = "../ted-search.tar"
      destination = "/home/ubuntu/ted-search.tar"
    }

    provisioner "file" {
      source      = "../docker-compose.yml"
      destination = "/home/ubuntu/docker-compose.yml"
    }

    provisioner "remote-exec" {
      inline = [
        "docker load -i ted-search.tar",
        "docker compose up -d"
      ]
    }

  tags = {
  	Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
  volume_tags = {
    Name       = var.name
    bootcamp   = var.bootcamp
    created_by = var.created_by
  }
}
