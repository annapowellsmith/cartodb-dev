#!/usr/bin/env bash

cd /usr/local/src/cartodb
bundle install

mv config/app_config.yml.sample config/app_config.yml
mv config/database.yml.sample config/database.yml

# get postgres to drop all security
mv /etc/postgresql/9.1/main/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf.original
ln -s /usr/local/etc/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf

/etc/init.d/postgresql restart

sleep 5s

export USER=monkey
export PASSWORD=monkey
export ADMIN_PASSWORD=monkey
export EMAIL=monkey@example.com

echo "127.0.0.1 ${USER}.localhost.lan" | sudo tee -a /etc/hosts

bundle exec rake rake:db:create
bundle exec rake rake:db:migrate
bundle exec rake cartodb:db:create_publicuser
bundle exec rake cartodb:db:create_user SUBDOMAIN="${USER}" PASSWORD="${PASSWORD}" EMAIL="${EMAIL}"
bundle exec rake cartodb:db:create_importer_schema
bundle exec rake cartodb:db:load_functions

ln -s /usr/local/etc/cartodb.development.js /usr/local/src/CartoDB-SQL-API/config/environments/development.js
ln -s /usr/local/etc/windshaft.development.js /usr/local/src/Windshaft-cartodb/config/environments/development.js

/etc/init.d/redis-server stop
