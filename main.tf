
variable "project_name" {
  type = string
  description = "プロジェクト名"
  default = "learning_amazon_document_db"
}

variable "allowed_ip_address" {
  type = string
  description = "インターネットからのアクセスを許可するIPアドレス"
}

variable "username" {
  type = string
  description = "データベースのユーザ名"
}

variable "password" {
  type = string
  description = "データベースのパスワード"
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa.pub"
  description = "Path to the public key."
}

# プロバイダーを設定
provider "aws" {
  region = "ap-northeast-1"
}

# インターネットゲートウェイを定義
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# VPCを定義
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# サブネットを定義
resource "aws_subnet" "example" {
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.0.0/24"
}

# ルーティングテーブルを定義
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

# ルーティングテーブルとサブネットを関連付ける
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}


# サブネット1を定義
resource "aws_subnet" "example1" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
}

# サブネット2を定義
resource "aws_subnet" "example2" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
}

# DocumentDBサブネットグループを定義
resource "aws_docdb_subnet_group" "example" {
  name       = "${var.project_name}-subnet-group-docdb"
  subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id] # 2つ以上の異なるAZにあるサブネットIDを指定する
}

# セキュリティグループを定義
resource "aws_security_group" "example" {
  name_prefix = "${var.project_name}-security-group"
  vpc_id      = aws_vpc.example.id

  ingress {
    description      = "SSH connection"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.allowed_ip_address}/32"]
  }
  ingress {
    description      = "HTTP connection"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTPS connection"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "Amazon DocumentDB connection"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.example1.cidr_block, "${var.allowed_ip_address}/32"] # `IPAddr/32`でそのIPアドレスのみを許可
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "name" = "${var.project_name}-security-group"
  }
}

# DocumentDBクラスターを定義
resource "aws_docdb_cluster" "example" {
  cluster_identifier      = "${replace(var.project_name, "_", "-")}-docdb-cluster"
  engine                  = "docdb"
  master_username         = var.username
  master_password         = var.password
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.example.id]
  db_subnet_group_name    = aws_docdb_subnet_group.example.name # 作成したDBサブネットグループの名前を指定
}

# DocumentDBクラスターインスタンスを定義
resource "aws_docdb_cluster_instance" "example" {
  identifier         = "${replace(var.project_name, "_", "-")}-docdb-instance"
  cluster_identifier = aws_docdb_cluster.example.id
  instance_class     = "db.t3.medium"
  count              = 1
}

# キーペアを定義
resource "aws_key_pair" "example" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# Elastic IPを定義
resource "aws_eip" "example" {
  vpc = true
}

# EC2インスタンスを定義
resource "aws_instance" "example" {
  ami = "ami-be4a24d9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id = aws_subnet.example.id
  associate_public_ip_address = true
  tags = {
    Name = "${var.project_name}-ec2"
  }
}

resource "local_file" "connection_string" {
  content  = "mongodb://${var.username}:${var.password}@${aws_docdb_cluster.example.endpoint}:27017/?ssl=true"
  filename = "${path.module}/connection_string.secret"
}
