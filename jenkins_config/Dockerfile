FROM jenkins/jenkins:lts

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

USER root

RUN apt-get update && apt-get install -y curl gnupg wget unzip

RUN apt-get install -y docker.io

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

RUN wget https://releases.hashicorp.com/terraform/1.14.1/terraform_1.14.1_linux_amd64.zip && \
    unzip terraform_1.14.1_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm terraform_1.14.1_linux_amd64.zip

USER jenkins