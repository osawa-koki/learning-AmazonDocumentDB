# learning-AmazonDocumentDB

👓👓👓 Amazon DocumentDBを学ぶためのリポジトリ。  

![成果物](./docs/img/fruit.png)  

## 環境情報

| Name | Version |
| --- | --- |
| Terraform | v1.3.7 |
| AWS CLI | 2.9.17 |

## 環境構築

Terraformを使用してAWS上にリソースを構築する。  

```shell
terraform init
terraform plan
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

TerraformでEC2インスタンスを作成する際に、自動で実行されます。  
MongoDBのクライアントツールをインストールする。  

```shell
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update && sudo apt install mongodb-org-shell
```

### 証明書のダウンロード

Amazon DocumentDBの証明書をダウンロードする。  

```shell
wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
```

### 接続

Amazon DocumentDBに接続する。  
具体的なコマンドはDocumentDBのコンソール画面から確認できます。  
※プライマリインスタンスの詳細画面です。  

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
