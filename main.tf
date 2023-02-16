
variable "allowed_ip_address" {
  type = string
  description = "インターネットからのアクセスを許可するIPアドレス"
}

# プロバイダーを設定
provider "aws" {
  region = "ap-northeast-1"
}

# VPCを定義
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# サブネットを定義
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
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
  master_username      = "admin"
  master_password      = "example"
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.example.id]
  db_subnet_group_name = "example"
}

# DocumentDBサブネットグループを定義
resource "aws_docdb_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.example.id]
}
