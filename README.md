# learning-AmazonDocumentDB

👓👓👓 Amazon DocumentDBを学ぶためのリポジトリ。  

## 環境情報

| Name | Version |
| --- | --- |
| Terraform | v1.3.7 |
| AWS CLI | 2.9.17 |

## 環境構築

Terraformを使用してAWS上にリソースを構築する。  

```shell
terraform init
terraform apply
```

## 実行方法

Amazon DocumentDBはMongoDBの互換性があるため、MongoDBのクライアントツールを使用して接続する。  
また、パブリックアクセスができないため、VPC内から接続する必要がある。  
したがって、同一のVPC内に構築したEC2インスタンスから接続する。  

Terraformを実行すると、以下のリソースが作成される。  

| Name | Description |
| --- | --- |
| VPC | Amazon DocumentDBを構築するVPC |
| Subnet | Amazon DocumentDBを構築するサブネット |
| SecurityGroup | Amazon DocumentDBを構築するセキュリティグループ |
| EC2 | Amazon DocumentDBに接続するためのEC2インスタンス |
| DocumentDB | Amazon DocumentDB |

このEC2インスタンスからAmazon DocumentDBに接続する。  

### EC2インスタンスへの接続

EC2インスタンスに接続する。  

```shell
ssh IPアドレス(ホスト名) -i プライベートキーファイル -l ユーザー名 -p ポート番号(22)
```

### MongoDBクライアントツールのインストール

MongoDBのクライアントツールをインストールする。  

```shell
sudo apt install mongodb-clients -y
```

### 証明書のダウンロード

Amazon DocumentDBの証明書をダウンロードする。  

```shell
wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
```

### 接続

Amazon DocumentDBに接続する。  

```shell
mongo --host エンドポイント --port ポート番号 --ssl --sslCAFile 証明書ファイル --username ユーザ名 --password パスワード [--authenticationMechanism=MONGODB-AWS]
```

## イロイロ情報共有

### パブリックアクセス不可

Amazon DocumentDBのインスタンスはパブリックアクセスができない。  
※[公式サイト](https://aws.amazon.com/jp/premiumsupport/knowledge-center/documentdb-cannot-connect/)より。  

### MongoDB接続トラブル

[公式QA](https://docs.aws.amazon.com/ja_jp/documentdb/latest/developerguide/troubleshooting.connecting.html)を参考にする。  

以下のコマンドでエンドポイントに対する接続が可能か確認する。  
※[公式サイト](https://docs.aws.amazon.com/ja_jp/documentdb/latest/developerguide/troubleshooting.connecting.html)より。  

```shell
nc -zv cluster-endpoint port
```
