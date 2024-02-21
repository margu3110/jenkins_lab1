data "aws_vpc" "default_vpc" {
  default = true
} 

#Create security group for EC2 server with Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins security group"
  description = "Allow access to ports 8080 and 22"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description = "allow all traffic to 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
   ingress {
    description = "allow all traffic to 22"
    from_port   = 22
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

  tags = {
    Name = "allow_tls"
  }
}

# Terraform Resource Block to create EC2 Jenkins Server
resource "aws_instance" "web_server" {
  ami                    = "ami-0e1d30f2c40c4c701"
  instance_type          = "t2.micro"
  security_groups        = [aws_security_group.jenkins_sg.name]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "isildur"
  user_data              = file("install_jenkins.sh")
  tags = {
    Name = "EC2 Jenkins Server"
  }
}


resource "aws_s3_bucket" "isildur-tf-jenkins-bucket" {
  bucket = "isildur-tf-jenkins-bucket-001"

  tags = {
    Name        = "isildur-tf-jenkins-bucket"
    Environment = "lab"
  }
}

resource "aws_s3_bucket_ownership_controls" "isildur-tf-jenkins-bucket" {
  bucket = aws_s3_bucket.isildur-tf-jenkins-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "isildur-tf-jenkins-bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.isildur-tf-jenkins-bucket]

  bucket = aws_s3_bucket.isildur-tf-jenkins-bucket.id
  acl    = "private"
}