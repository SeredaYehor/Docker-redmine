FROM ubuntu:20.04

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "GET NESSECARY PACKAGES"
RUN apt update
RUN apt install wget mysql-client ruby ruby-dev build-essential libmysqlclient-dev imagemagick libmagickwand-dev libmagickcore-dev libcurl4-openssl-dev -y

RUN echo "INSTALL REDMINE"
RUN wget https://redmine.org/releases/redmine-5.0.1.tar.gz
RUN tar -xvzf ./redmine-5.0.1.tar.gz -C /usr/share

WORKDIR /usr/share/redmine-5.0.1/config
RUN cp database.yml.example database.yml

RUN echo "INSTALL ADDITIONAL PACKAGES"
WORKDIR /usr/share/redmine-5.0.1
RUN gem install bundler
RUN gem install passenger

RUN bundle install

RUN apt install -y dirmngr gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt install -y apt-transport-https ca-certificates
RUN echo deb [arch=amd64] https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list
RUN apt update
RUN apt install -y libnginx-mod-http-passenger

RUN apt install -y nginx-extras systemctl curl expect sudo 

RUN mkdir -p tmp tmp/pdf public/plugin_assets
RUN chown -R www-data:www-data files log tmp public/plugin_assets
RUN chmod -R 775 files log tmp public/plugin_assets

COPY init.sh expect_init load_data /usr/bin/
RUN chmod +x /usr/bin/init.sh /usr/bin/expect_init /usr/bin/load_data

RUN useradd -ms /bin/bash nginx && usermod -aG sudo nginx
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>  /etc/sudoers

RUN chown nginx:nginx -R /etc/nginx/
RUN chown nginx:nginx /usr/share/redmine-5.0.1/config/database.yml
RUN usermod -aG www-data nginx

USER nginx
ENTRYPOINT ["init.sh"]
