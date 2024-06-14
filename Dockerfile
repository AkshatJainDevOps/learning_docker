# Use the official Jenkins LTS image as the base image
FROM jenkins/jenkins:lts-jdk17

# Switch to root user to install Docker
USER root

# Install Docker dependencies and Docker itself
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get install docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

RUN curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose &&  \
    chmod +x /usr/local/bin/docker-compose

RUN ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# Add Jenkins user to the Docker group
RUN groupadd docker && usermod -aG docker jenkins

COPY . /var/jenkins_home/workspace

# Switch back to the Jenkins user
USER jenkins

# Set Docker host environment variable (if necessary)
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Start Jenkins
ENTRYPOINT ["/usr/local/bin/jenkins.sh"]

