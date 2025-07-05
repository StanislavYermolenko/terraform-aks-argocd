FROM docker.io/jenkins/inbound-agent:latest-jdk11

USER root

# Install Podman and dependencies
RUN apt-get update && \
    apt-get install -y podman && \
    apt-get clean

USER jenkins