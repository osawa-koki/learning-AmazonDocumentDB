
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

# サブネット1を定義
resource "aws_subnet" "example" {
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
  name       = "example"
  subnet_ids = [aws_subnet.example.id, aws_subnet.example2.id] # 2つ以上の異なるAZにあるサブネットIDを指定する
}

# セキュリティグループを定義
resource "aws_security_group" "example" {
  name_prefix = "example"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.example.cidr_block, "${var.allowed_ip_address}/32"] # `IPAddr/32`でそのIPアドレスのみを許可
  }
}

# DocumentDBクラスターを定義
resource "aws_docdb_cluster" "example" {
  cluster_identifier   = "example"
  engine               = "docdb"
  master_username      = var.username
  master_password      = var.password
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.example.id]
  db_subnet_group_name = aws_docdb_subnet_group.example.name # 作成したDBサブネットグループの名前を指定
}
