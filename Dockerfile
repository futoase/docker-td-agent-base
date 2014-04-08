FROM centos

MAINTIANER Keiji Matsuzaki <futoase@gmail.com>

# setup remi repository
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN curl -O http://rpms.famillecollet.com/RPM-GPG-KEY-remi; rpm --import RPM-GPG-KEY-remi
RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
RUN yum -y update
RUN yum -y upgrade

# install the sshd
RUN yum -y install openssh-server

# setup network
# reference from https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# set time zone
RUN rm -f /etc/localtime
RUN cp /usr/share/zoneinfo/UTC /etc/localtime

# setup td-agent repository
ADD ./templates/td-agent.repo /etc/yum.repos.d/td-agent.repo
RUN yum -y update
RUN yum -y upgrade
RUN yum -y install td-agent enablerepo=treasuredata
RUN chkconfig td-agent on

# set td-agent.conf on /etc/td-agent dir
ADD ./templates/td-agent.conf /etc/td-agent/td-agent.conf
RUN chmod 0644 /etc/td-agent/td-agent.conf
RUN chown td-agent:td-agent /etc/td-agent/td-agent.conf
RUN service td-agent start # check the start of service

RUN mkdir -p /var/scripts
ADD ./scripts/startup.sh /var/scripts/startup.sh
RUN chmod +x /var/scripts/startup.sh

EXPOSE 24224 24220
ENTRYPOINT ["/var/scripts/startup.sh"]
