# v1からの移行方法

```sh
# 別途フォーク等して利用している方に自分のブランチに本リポジトリをマージしてください。
git pull
# ファイルを最新のサンプルファイルと見比べて適宜更新してください。
vim docker-compose.yml
# DBをマイグレーションするのでいったん終了
docker-compose kill epgstation && docker-compose rm -f epgstation
# DBを更新するためコンテナに入る
docker-compose run --rm epgstation sh
# 最新のv1にして起動するその後起動完了したらCtrl + Cで終了
git pull && git checkout v1.7.5 && npm install --no-save && npm run build && npm start
# 下記コマンドでバックアップファイルを作成する
npm run backup config/backup
# コンテナを抜ける
exit
# 各種設定を最新のものに追従させて古いjsonは削除する
cp epgstation/config/config.sample.yml epgstation/config/config.yml
vim epgstation/config/config.yml
cp epgstation/config/operatorLogConfig.sample.yml epgstation/config/operatorLogConfig.yml
vim epgstation/config/operatorLogConfig.yml
cp epgstation/config/serviceLogConfig.sample.yml epgstation/config/serviceLogConfig.yml
vim epgstation/config/serviceLogConfig.yml
rm -f epgstation/config/*.json
cp epgstation/config/epgUpdaterLogConfig.sample.yml epgstation/config/epgUpdaterLogConfig.yml
# v1の頃のDBのデータを削除
docker-compose down -v && docker-compose up -d mirakurun mysql
# v2にイメージを更新
docker-compose build --pull --no-cache
# v1からデータをマイグレーション
docker-compose run --rm sh -c "npm run v1migrate config/backup"
# 起動
docker-compose up -d
```