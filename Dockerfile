FROM openjdk:11-jdk-stretch

ARG user=jenkins

ENV JENKINS_HOME /home/jenkins

RUN apt-get update -qqy \
  && apt-get -qqy install openssh-server git nodejs ruby build-essential zlib1g-dev \
  && apt-get -qqy install ruby$(ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]')-dev \
  && apt-get clean

RUN gem install bundler:'2.0.1' concurrent-ruby:'1.0.5' i18n:'0.7.0' minitest:'5.10.1' thread_safe:'0.3.5' tzinfo:'1.2.2' \
    public_suffix:'2.0.5' addressable:'2.5.0' execjs:'2.7.0' autoprefixer-rails:'6.6.1' coffee-script-source:'1.12.2' \
    coffee-script:'2.4.1' sass:'3.4.23' compass-import-once:'1.0.5' contracts:'0.13.0' dotenv:'2.2.0' erubis:'2.7.0' \
    fast_blank:'1.0.0' fastimage:'2.0.1' ffi:'1.9.17' tilt:'2.0.6' haml:'4.0.7' hamster:'3.0.0' hashie:'3.5.1' \
    kramdown:'1.13.2' rb-fsevent:'0.9.8' rb-inotify:'0.9.8' listen:'3.0.8' memoist:'0.15.0' thor:'0.19.4' \
    middleman-cli:'4.2.1' padrino-support:'0.13.3.3' padrino-helpers:'0.13.3.3' parallel:'1.10.0' rack:'2.0.5' \
    servolux:'0.12.0' uglifier:'3.0.4' middleman-core:'4.2.1' middleman:'4.2.1' middleman-autoprefixer:'2.7.1' \
    sprockets:'3.7.2' middleman-sprockets:'4.1.0' rouge:'2.0.7' middleman-syntax:'3.0.0' mini_portile2:'2.3.0'\
    nokogiri:'1.8.2' redcarpet:'3.4.0' activesupport:'5.0.1' backports:'3.6.8'

RUN useradd -d "$JENKINS_HOME" -m -s /bin/bash ${user}
RUN sed -i 's|session required pam_loginuid.so|session optional pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

RUN echo "jenkins:jenkins" | chpasswd

USER jenkins

RUN mkdir /home/jenkins/.ssh ; chmod 700 /home/jenkins/.ssh ; printf "Host review.upaid.pl\n  KexAlgorithms +diffie-hellman-group1-sha1" >/home/jenkins/.ssh/config

RUN mkdir "$JENKINS_HOME/.m2"

COPY files/settings.xml "$JENKINS_HOME/.m2"

USER root

EXPOSE 2022

CMD env | grep _SETTINGS_ >> /etc/environment && /usr/sbin/sshd -p 2022 -D
