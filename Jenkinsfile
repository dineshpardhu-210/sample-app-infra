pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = 'dockerhub-creds'
    KUBECONFIG_CRED = 'kubeconfig'
    IMAGE_NAME = "<DOCKERHUB_USER>/sample-app"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build Image') { steps { sh 'docker build -t ${IMAGE_NAME}:latest .' } }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CRED, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo "$PASS" | docker login -u "$USER" --password-stdin'
          sh 'docker push ${IMAGE_NAME}:latest'
        }
      }
    }
    stage('Deploy to EKS') {
      steps {
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh 'mkdir -p $HOME/.kube && cp $KUBECONFIG_FILE $HOME/.kube/config'
          sh 'kubectl apply -f infra/k8s/'
        }
      }
    }
  }
}
