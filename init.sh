#!/bin/bash

echo "Configuring database"
if [ -z "$DB_HOST" ]; then
  echo "Container failed to start, pls pass -e DB_HOST=database_ip"
  exit 1
fi

cd /usr/share/redmine-5.0.1/config

cat << EOF > database.yml
production:
  adapter: mysql2
  database: redmine
  host: ${DB_HOST}
  username: redmine
  password: "redm1n3"
  encoding: utf8mb4
EOF

sudo bundle exec rake generate_secret_token
sudo RAILS_ENV=production bundle exec rake db:migrate
sudo expect_init

cd /etc/nginx/sites-available

cat << EOF > default
server	{
	listen 80 default;
	root /usr/share/redmine-5.0.1/public/;
	passenger_enabled on;
	passenger_ruby /usr/bin/ruby2.7;
}
EOF

sudo systemctl start nginx
while true; 
do 
	sleep 1; 
done
