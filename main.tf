
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

# プロバイダーを設定
provider "aws" {
  region = "ap-northeast-1"
}

# VPCを定義
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# インターネットゲートウェイを定義
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
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
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.example1.cidr_block, "${var.allowed_ip_address}/32"] # `IPAddr/32`でそのIPアドレスのみを許可
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DocumentDBクラスターを定義
resource "aws_docdb_cluster" "example" {
  cluster_identifier      = "${replace(var.project_name, "_", "-")}-docdb"
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

resource "local_file" "connection_string" {
  content  = "mongodb://${var.username}:${var.password}@${aws_docdb_cluster.example.endpoint}:27017/?ssl=true"
  filename = "${path.module}/connection_string.secret"
}
