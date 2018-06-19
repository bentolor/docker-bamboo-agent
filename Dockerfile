#
# Bamboo Agent Dockerfile
#
# - Maven 3.5
# - JDK 8,9,10
# - Yarn
# - Node 8.x LTS
# - Groovy
# - IntelliJ IDEA
#

FROM        ubuntu:16.04
MAINTAINER  Benjamin Schmid <setec@gmx.net>

# Make full package install & cleanup in one docker RUN statement
# to avoid large leftovers in docker image history & cache
RUN apt-get update && \
    apt-get dist-upgrade -yqq && \
    apt-get install -y curl wget openssh-client software-properties-common apt-utils sudo && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.* && \
    rm -fr /tmp/* /var/tmp/*

# Install Oracle Java PPAs
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN echo "deb http://ppa.launchpad.net/linuxuprising/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/linuxuprising-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 73C3DB2A

# Mark Oracle license accepted
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN echo oracle-java10-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                       build-essential \
                       git subversion \
                       oracle-java8-installer \
                       oracle-java8-set-default \
                       oracle-java8-unlimited-jce-policy \
                       oracle-java10-installer \
                       groovy \
                       graphviz && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -fr /var/cache/oracle-jdk* && \
    rm /var/lib/apt/lists/*.* && \
    rm -fr /tmp/* /var/tmp/*

# Install chromium with all dependencies for headless as proposed by
# https://docs.browserless.io/blog/2018/06/04/puppeteer-best-practices.html
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                        chromium-browser fonts-freefont-ttf libx11-xcb1 unzip \
                        fontconfig locales gconf-service libasound2 \
                        libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 \
                        libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
                        libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 \
                        libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
                        libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
                        libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation \
                        libappindicator1 libnss3 lsb-release xdg-utils && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.* && \
    rm -fr /tmp/* /var/tmp/*

# Install node - this does an implicit apt-get update!
RUN ( curl -sL https://deb.nodesource.com/setup_8.x | bash - ) && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.* && \
    rm -fr /tmp/* /var/tmp/*

# Install grunt-cli
RUN npm install -g grunt-cli

#
# Install various tools into /srv 
#

# Install Maven
ENV V_MAVEN3 3.5.3
RUN cd /srv && \
    curl -sL http://mirror.synyx.de/apache/maven/maven-3/$V_MAVEN3/binaries/apache-maven-$V_MAVEN3-bin.tar.gz | tar -xz && \
    ln -s apache-maven-$V_MAVEN3 maven-3.x

# Install yarn
ENV V_YARN 1.7.0
RUN cd /srv && \
    curl -sL https://github.com/yarnpkg/yarn/releases/download/v$V_YARN/yarn-$V_YARN.js -o yarn-$V_YARN.js && \
    chmod +x yarn-$V_YARN.js && \
    ln -s yarn-$V_YARN.js yarn

# Install IntelliJ IDEA
ENV V_IDEA 2018.1.4
ENV V_IDEA_CONFDIR .IntelliJIdea2018.1
RUN cd /srv && \
    wget -nv https://download-cf.jetbrains.com/idea/ideaIU-$V_IDEA.tar.gz && \
    tar xf ideaIU-$V_IDEA.tar.gz && \
    ln -s idea-IU-* idea.latest && \
    mkdir ~/$V_IDEA_CONFDIR && \
    ln -s ~/$V_IDEA_CONFDIR idea.config.latest && \
    rm ideaIU-$V_IDEA.tar.gz

# Install groovy
ENV V_GROOVY 2.4.15
RUN cd /srv && \
    wget -nv https://dl.bintray.com/groovy/maven/apache-groovy-binary-$V_GROOVY.zip && \
    unzip -q apache-groovy-binary-$V_GROOVY.zip && \
    rm  apache-groovy-binary-$V_GROOVY.zip && \
    ln -s groovy-$V_GROOVY groovy

# Install Ant 1.10.x
ENV V_ANT_10 1.10.3
RUN cd /srv && \
    wget -nv http://ftp.fau.de/apache/ant/binaries/apache-ant-$V_ANT_10-bin.zip && \
    unzip -q apache-ant-$V_ANT_10-bin.zip && \
    rm  apache-ant-$V_ANT_10-bin.zip && \
    ln -s apache-ant-$V_ANT_10 ant-1.10.x && \
    ln -s apache-ant-$V_ANT_10 ant-latest

# Install Ant 1.9.x
ENV V_ANT_9 1.9.11
RUN cd /srv && \
    wget -nv http://ftp.fau.de/apache/ant/binaries/apache-ant-$V_ANT_9-bin.zip && \
    unzip -q apache-ant-$V_ANT_9-bin.zip && \
    rm  apache-ant-$V_ANT_9-bin.zip && \
    ln -s apache-ant-$V_ANT_9 ant-1.9.x

# Install Ant 1.8.x
RUN cd /srv && \
    wget -nv https://archive.apache.org/dist/ant/binaries/apache-ant-1.8.4-bin.zip && \
    unzip -q apache-ant-1.8.4-bin.zip && \
    rm  apache-ant-1.8.4-bin.zip && \
    ln -s apache-ant-1.8.4 ant-1.8.x

# Install Gradle
ENV V_GRADLE 4.8
RUN cd /srv && \
    wget -nv https://services.gradle.org/distributions/gradle-$V_GRADLE-all.zip && \
    unzip -q gradle-$V_GRADLE-all.zip && \
    rm  gradle-$V_GRADLE-all.zip && \
    ln -s gradle-$V_GRADLE gradle.latest

# Install NodeJS 6.x LTS
ENV V_NODE_6 6.14.2
RUN cd /srv && \
    wget -nv https://nodejs.org/download/release/latest-v6.x/node-v$V_NODE_6-linux-x64.tar.xz && \
    tar xf node-v$V_NODE_6-linux-x64.tar.xz && \
    rm node-v$V_NODE_6-linux-x64.tar.xz && \
    ln -s node-v$V_NODE_6-linux-x64 node-6.x

# Install NodeJS 4.x LTS -- End-of-life after April 2018! --
ENV V_NODE_4 4.9.1
RUN cd /srv && \
    wget -nv https://nodejs.org/download/release/latest-v4.x/node-v$V_NODE_4-linux-x64.tar.xz && \
    tar xf node-v$V_NODE_4-linux-x64.tar.xz && \
    rm node-v$V_NODE_4-linux-x64.tar.xz && \
    ln -s node-v$V_NODE_4-linux-x64 node-4.x

# Install Chromedriver -- The version must match the installed chromium-browser version!
#    More details about the version link between chromium-browser <-> chromedriver see at:
#    https://sites.google.com/a/chromium.org/chromedriver/downloads
ENV V_CHROMEDRIVER 2.40
RUN cd /srv && \
    wget -nv https://chromedriver.storage.googleapis.com/$V_CHROMEDRIVER/chromedriver_linux64.zip && \
    unzip -q chromedriver_linux64.zip && \
    rm chromedriver_linux64.zip
    
#
# Fix upstream Docker template: Run bamboo as non-privileged user
#
# Create a bamboo user
RUN useradd -mUs /bin/bash bamboo

# Retrieve the Bamboo agent installer
ENV V_AGENT_INSTALLER 5.9.10
RUN wget -nv -O /home/bamboo/atlassian-bamboo-agent-installer.jar \ 
    https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-agent-installer/$V_AGENT_INSTALLER/atlassian-bamboo-agent-installer-$V_AGENT_INSTALLER.jar

# Copy our updated bamboo-capabilities.properties
COPY bamboo-capabilities.properties  /home/bamboo/bamboo-agent-home/bin/bamboo-capabilities.properties

# Copy IDEA configuration into container
COPY bamboo /home/bamboo/
# Add /srv content like idea-cli-inspector
COPY srv /srv/

# Fix `root` users from COPY and other commands
RUN chown -R bamboo:bamboo /home/bamboo
# The idea-cli-inspector needs write access to the IDEA bin directory as a hack
RUN chown -R bamboo:bamboo /srv/idea.latest/bin

# Default to our bamboo Server
ENV    HOME=/root/
# Uncomment & adjust the following if you do not want to pass the target Bamboo instance everytime.
#ENV    BAMBOO_SERVER=https://bamboo.mycorp.com:1234/

# The default locale is POSIX which breaks UTF-8 based javac files
RUN locale-gen en_US.UTF-8
ENV    LANG "en_US.UTF-8"
ENV    LC_MESSAGES "C"
ENV    LC_ALL "en_US.UTF-8"

# Provide an entry point script which also creates starts Bamboo with a
# dedicated user
ENTRYPOINT ["/home/bamboo/docker-entrypoint.sh"]

# Define default command.
CMD ["bamboo-agent"]