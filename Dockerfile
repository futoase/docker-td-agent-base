FROM centos

MAINTIANER Keiji Matsuzaki <futoase@gmail.com>

# setup remi repository
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN curl -O http://rpms.famillecollet.com/RPM-GPG-KEY-remi; rpm --import RPM-GPG-KEY-remi
RUN rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
RUN yum -y update
RUN yum -y upgrade

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
RUN yum -y install td-agent
RUN chkconfig td-agent on

RUN mkdir -p /var/scripts
ADD ./scripts/startup.sh /var/scripts/startup.sh
RUN chmod +x /var/scripts/startup.sh
CMD ["/var/scripts/startup.sh"]
