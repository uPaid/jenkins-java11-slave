FROM openjdk:11-jdk-stretch

ARG user=jenkins

ENV JENKINS_HOME /home/jenkins

RUN apt-get update -qqy \
  && apt-get -qqy install openssh-server git \
  && apt-get clean

RUN useradd -d "$JENKINS_HOME" -m -s /bin/bash ${user}
RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
RUN echo "jenkins:jenkins" | chpasswd
RUN mkdir /home/jenkins/.ssh ; chmod 700 /home/jenkins/.ssh ; printf "Host review.upaid.pl\n  KexAlgorithms +diffie-hellman-group1-sha1" >/home/jenkins/.ssh/config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
