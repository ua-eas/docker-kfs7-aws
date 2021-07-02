ARG  DOCKER_REGISTRY
ARG  BASE_IMAGE_TAG_DATE
FROM $DOCKER_REGISTRY/kuali/tomcat8:java11tomcat8-ua-release-$BASE_IMAGE_TAG_DATE
ARG  KUALICO_TAG
ENV  KUALICO_TAG=$KUALICO_TAG

RUN groupadd -r kuali && useradd -r -g kuali kualiadm

# copy in the tomcat utility scripts
COPY bin /usr/local/bin/

# set kfs web app directory owner and group
RUN chmod +x /usr/local/bin/*

# set up default umask for root for new files created during batch
RUN echo "umask 002" >> /root/.bashrc

# create some useful shortcut environment variables
ENV TOMCAT_BASE_DIR=$CATALINA_HOME
ENV TOMCAT_SHARE_LIB=$TOMCAT_BASE_DIR/lib
ENV TOMCAT_SHARE_BIN=$TOMCAT_BASE_DIR/bin
ENV TOMCAT_WEBAPPS_DIR=$TOMCAT_BASE_DIR/webapps
ENV TOMCAT_KFS_DIR=$TOMCAT_WEBAPPS_DIR/kfs
ENV TOMCAT_KFS_WEBINF_DIR=$TOMCAT_KFS_DIR/WEB-INF
ENV TRANSACTIONAL_DIRECTORY=/transactional
ENV CONFIG_DIRECTORY=/configuration
ENV LOGS_DIRECTORY=/logs
ENV SECURITY_DIRECTORY=/security
ENV SMTP_SECURITY_DIRECTORY=/security/smtp
ENV TOMCAT_CONFIG_DIRECTORY=/configuration/tomcat-config
ENV KFS_CONFIG_DIRECTORY=/configuration/kfs-config
ENV TOMCAT_KFS_CORE_DIR=$TOMCAT_KFS_DIR/kfs-core-ua
ENV UA_DB_CHANGELOGS_DIR=$TOMCAT_KFS_CORE_DIR/changelogs
ENV UA_KFS_INSTITUTIONAL_CONFIG_DIR=$TOMCAT_KFS_DIR/kfs-core-ua
ENV TOMCAT_KFS_METAINF_DIR=$TOMCAT_KFS_DIR/META-INF
ENV LIQUIBASE_HOME=/opt/liquibase

# copy in the New Relic jar file
COPY classes $TOMCAT_SHARE_LIB

# setup log rotate
# theoretically logrotate will run every hour and use the configuration defined in the /etc/logrotate.d/tomcat file
RUN mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
ADD logrotate /etc/logrotate.d/tomcat
RUN chmod 644 /etc/logrotate.d/tomcat

# Copy the Application WAR in
COPY files/kfs.war $TOMCAT_KFS_DIR/kfs.war

# FIN-2165 Copy the generic error.jsp page into webapps folder to be later copied into the kfs context in tomcat-ctl
COPY webapp-files/error.jsp $TOMCAT_WEBAPPS_DIR/error.jsp

# Install Sendmail Services
#http://docs.aws.amazon.com/ses/latest/DeveloperGuide/sendmail.html
RUN yum -y install sendmail m4 sendmail-cf cyrus-sasl-plain

#Append /etc/mail/access file
RUN echo "Connect:email-smtp.us-west-2.amazonaws.com RELAY" >> /etc/mail/access
#Regenerate /etc/mail/access.db
RUN rm /etc/mail/access.db && sudo makemap hash /etc/mail/access.db < /etc/mail/access
#Save a back-up copy of /etc/mail/sendmail.mc and /etc/mail/sendmail.cf
RUN cp /etc/mail/sendmail.mc /etc/mail/sendmail.mc.old
RUN cp /etc/mail/sendmail.cf /etc/mail/sendmail.cf.old
#Update /etc/mail/sendmail.mc file with AWS Region info
COPY sendmail/sendmail.mc /etc/mail/sendmail.mc
RUN  sudo chmod 666 /etc/mail/sendmail.cf
RUN  sudo m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
RUN  sudo chmod 644 /etc/mail/sendmail.cf

# set up liquibase; update if version bump
RUN mkdir /opt/liquibase
COPY liquibase $LIQUIBASE_HOME
RUN cd $LIQUIBASE_HOME && \ 
    tar -zxvf $LIQUIBASE_HOME/liquibase-3.5.5-bin.tar.gz && \
    cd -
ENV PATH=$PATH:$LIQUIBASE_HOME

ENTRYPOINT /usr/local/bin/tomcat-start