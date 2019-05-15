FROM debian:latest 
MAINTAINER Daniel Thompson

EXPOSE 8140

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list

RUN apt-get update && apt-get install -t 'stretch-backports' -y puppetmaster vim

# Set environment variables.
ENV HOME /root

VOLUME puppet

# Define working directory.
WORKDIR /root

COPY ./start.sh /root/start.sh 
COPY certs/ /var/lib/puppet/ssl
ENTRYPOINT ["/root/start.sh"]

# Define default command.
#CMD ["bash"]
#CMD tail -f /dev/null

