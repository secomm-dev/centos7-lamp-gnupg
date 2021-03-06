FROM centos:7.5.1804
MAINTAINER Soulblade "phuocvu@builtwithdigital.com"

# Install GnuPG 2.2.x
ADD conf/install-gnupg.sh /root/install-gnupg.sh
RUN chmod +x /root/install-gnupg.sh && . /root/install-gnupg.sh && gpg --version
# Install Apache & PHP
RUN yum -y --setopt=tsflags=nodocs install httpd mysql vi crontabs unzip epel-release sudo haveged
# Install PHP 5.6
RUN wget https://centos7.iuscommunity.org/ius-release.rpm && rpm -Uvh ius-release*.rpm
RUN yum -y install php56u php56u-soap php56u-xml php56u-pdo php56u-mcrypt php56u-mbstring php56u-mysqlnd php56u-cli \
           php56u-gd php56u-bcmath php56u-pecl-imagick php56u-pecl-redis php56u-intl php56u-pear php56u-devel
# Install PHP gnupg extension
RUN pecl install gnupg
RUN echo "extension=gnupg.so" > /etc/php.d/gnupg.ini
# Install Magerun
RUN wget https://files.magerun.net/n98-magerun.phar && chmod +x ./n98-magerun.phar && mv ./n98-magerun.phar /usr/bin/
# Install composer
RUN wget https://getcomposer.org/composer.phar && chmod +x composer.phar && mv composer.phar /usr/bin/composer
# Config PHP
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini
RUN sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php.ini
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php.ini
RUN sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
# Config apache
COPY conf/httpd.conf /etc/httpd/conf/httpd.conf
RUN sed -i 's/LoadModule authn_anon_module/#LoadModule authn_anon_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authn_dbm_module/#LoadModule authn_dbm_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authz_dbm_module/#LoadModule authz_dbm_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authz_groupfile_module/#LoadModule authz_groupfile_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule authz_owner_module/#LoadModule authz_owner_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule cache_module/#LoadModule cache_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule cache_disk_module/#LoadModule cache_disk_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule ext_filter_module/#LoadModule ext_filter_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule include_module/#LoadModule include_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule info_module/#LoadModule info_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule logio_module/#LoadModule logio_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule status_module/#LoadModule status_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule substitute_module/#LoadModule substitute_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule userdir_module/#LoadModule userdir_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule vhost_alias_module/#LoadModule vhost_alias_module/g' /etc/httpd/conf.modules.d/00-base.conf \
 && sed -i 's/LoadModule proxy_ajp_module/#LoadModule proxy_ajp_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_balancer_module/#LoadModule proxy_balancer_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_connect_module/#LoadModule proxy_connect_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_ftp_module/#LoadModule proxy_ftp_module/g' /etc/httpd/conf.modules.d/00-proxy.conf \
 && sed -i 's/LoadModule proxy_http_module/#LoadModule proxy_http_module/g' /etc/httpd/conf.modules.d/00-proxy.conf
# Create sudo user
RUN adduser -d /home/web web
RUN usermod -aG root web && usermod -aG apache web
RUN echo "web      ALL=(ALL)       ALL" >> /etc/sudoers
RUN mkdir -p /home/web/.gnupg && \
chown -R web:web /home/web/.gnupg && \
su -s /bin/bash -c "gpg -k" web && \
su -s /bin/bash -c "echo 'allow-loopback-pinentry' >> /home/web/.gnupg/gpg-agent.conf && \
echo 'pinentry-mode loopback' >> /home/web/.gnupg/gpg.conf" web
# Clean CentOS 7
RUN yum clean all && rm -rf /var/cache/yum/*

VOLUME ["/var/www/html", "/etc/httpd/conf.d/", "/var/log/httpd/"]
WORKDIR /var/www/html

# Simple startup script to avoid some issues observed with container restart
ADD conf/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh", "/usr/sbin/crond", "/usr/sbin/haveged -F"]
