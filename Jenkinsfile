#!groovy
//  groovy Jenkinsfile
properties([disableConcurrentBuilds()])\

pipeline  {
        agent { 
           label ''
        }
    stages {
        stage("init") {
            steps {
                checkout scm         
          }
        }    
        stage("Build") {
            steps {
                sh '''
                terraform init
                '''
            }
        } 
        stage("plan") {
            steps {
                sh '''
                terraform plan -out=tfplan
                '''
            }
        }
        stage("apply") {
            steps {
                sh '''
                terraform apply -auto-approve tfplan
                '''
          }
       }
    }
}
