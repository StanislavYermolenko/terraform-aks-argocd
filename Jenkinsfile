pipeline {
    agent any
    triggers {
        pollSCM('H/2 * * * *') // Poll every 2 minutes; adjust as needed
    }
    environment {
        REGISTRY = "ghcr.io/stanislavyermolenko/terraform-aks-argocd"
        IMAGE_TAG = "jenkins-podman-agent:inbound-agent3206"
        PODMAN_USER = credentials('GITHUB_USERNAME')
        PODMAN_PASS = credentials('GITHUB_TOKEN')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Check for index.html changes') {
            when {
                changeset "image/index.html"
            }
            steps {
                script {
                    echo "index.html changed, proceeding with build and push."
                }
            }
        }
        stage('Build & Push Image') {
            when {
                changeset "image/index.html"
            }
            steps {
                sh '''
                cd image
                echo $PODMAN_PASS | podman login ghcr.io -u $PODMAN_USER --password-stdin
                podman build -t $REGISTRY:$IMAGE_TAG .
                podman push $REGISTRY:$IMAGE_TAG
                '''
            }
        }
    }
}