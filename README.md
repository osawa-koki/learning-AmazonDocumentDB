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

## イロイロ情報共有

### データベースクライアント

Amazon DocumentDB(MongoDB)のGUIクライアントツールは[こちら](https://downloads.mongodb.com/compass/mongodb-compass-1.35.0-win32-x64.exe)からダウンロード可能。  
※ ダウンロードページは[こちら](https://www.mongodb.com/try/download/compass)から。  

### パブリックアクセス不可

Amazon DocumentDBのインスタンスはパブリックアクセスができない。  
※[公式サイト](https://aws.amazon.com/jp/premiumsupport/knowledge-center/documentdb-cannot-connect/)より。  

### MongoDB接続トラブル

[公式QA](https://docs.aws.amazon.com/ja_jp/documentdb/latest/developerguide/troubleshooting.connecting.html)を参考にする。  
