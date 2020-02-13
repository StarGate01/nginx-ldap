FROM debian:10.2

MAINTAINER Ondrej Burkert <ondrej.burkert@gmail.com>

ENV NGINX_VERSION release-1.16.1

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
	&& apt-get update \
	&& apt-get install -y \
		ca-certificates \
		git \
		gcc \
		make \
		libpcre3-dev \
		zlib1g-dev \
		libldap2-dev \
		libssl-dev \
		wget \
                perl \
                libperl-dev

# See http://wiki.nginx.org/InstallOptions
RUN mkdir /var/log/nginx \
	&& mkdir /etc/nginx \
	&& cd ~ \
	&& git clone https://github.com/kvspb/nginx-auth-ldap.git \
	&& git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git \
        && git clone https://github.com/atomx/nginx-http-auth-digest.git \
	&& git clone https://github.com/nginx/nginx.git \
	&& cd ~/nginx \
	&& git checkout tags/${NGINX_VERSION} \
	&& ./auto/configure \
        --add-module=/root/nginx-auth-ldap \
        --add-module=/root/nginx-sticky-module-ng \
        --add-module=/root/nginx-http-auth-digest \
        --with-debug \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-file-aio \
        --with-threads \
        --with-ipv6 \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_perl_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-cc-opt='-g \
        -O2 \
        -fstack-protector-strong \
        -Wformat \
        -Werror=format-security \
        -Wp,-D_FORTIFY_SOURCE=2' \
        --with-ld-opt='-Wl,-z,relro \
        -Wl,-z,now \
        -Wl,--as-needed' \
	&& make install \
	&& cd .. \
	&& rm -rf nginx-auth-ldap \
	&& rm -rf nginx-sticky-module-ng \
	&& rm -rf nginx

EXPOSE 80 443

RUN groupadd nginx \
    && useradd -ms /bin/sh -g nginx nginx \
    && mkdir /var/cache/nginx \
    && mkdir /var/cache/nginx/client_temp \
    && chmod -R 766 /var/log/nginx /var/cache/nginx \
    && chmod 644 /etc/nginx/*

CMD ["nginx","-g","daemon off;error_log /dev/stdout info;access_log /dev/stdout;"]
