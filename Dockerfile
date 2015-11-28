FROM robbertkl/base
MAINTAINER Robbert Klarenbeek <robbertkl@renbeek.nl>

# Install packages and clean up after apt
RUN cleaninstall \
    dovecot-core \
    dovecot-imapd \
    dovecot-managesieved \
    dovecot-sieve \
    milter-greylist \
    opendkim \
    opendmarc \
    postfix \
    postfix-policyd-spf-python

# Configure services
RUN rm -rf /etc/dovecot/*
COPY etc /etc

# Setup rights and logging
RUN groupadd -g 5000 vmail \
    && useradd -u 5000 -g vmail -s /usr/sbin/nologin -d /nonexistent vmail \
    && usermod -a -G greylist,opendkim,opendmarc postfix \
    && bash -c "mkdir -p /var/spool/postfix/{greylist,opendkim,opendmarc}" \
    && chown greylist: /var/spool/postfix/greylist \
    && chown opendkim: /var/spool/postfix/opendkim \
    && chown opendmarc: /var/spool/postfix/opendmarc \
    && bash -c "touch /var/log/mail.{err,log}" \
    && echo /var/log/mail.err >> /etc/services.d/logs/stderr \
    && echo /var/log/mail.log >> /etc/services.d/logs/stdout

# Persistent storage
RUN mkdir /data \
    && mkdir /data/dkim \
    && mkdir /data/mail \
    && chown vmail:vmail /data/mail \
    && touch /data/users \
    && chmod 666 /data/users \
    && touch /data/virtual
VOLUME /data

# Expose mail port (SMTP, IMAP and ManageSieve)
EXPOSE 25
EXPOSE 143
EXPOSE 587
EXPOSE 993
EXPOSE 4190