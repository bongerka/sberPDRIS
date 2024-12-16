Скрипт пайплайна

```
pipeline {
    agent any

    stages {

        stage('Clone') {
            steps {
                git branch: 'lab4', url: 'https://github.com/bongerka/sberPDRIS.git'
            }
        }

        stage('Test') {
            steps {
                sh "cd src && go test ./internal/utils -coverprofile=coverage.out"
            }
        }

        stage('Allure') {
            steps {
                allure([
                    reportBuildPolicy: 'ALWAYS',
                    results: [[path: 'src/internal/utils/allure-results']]
                ])
            }
        }

        stage('Sonar') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    tool name: 'maven', type: 'maven'
                    sh 'cd src && mvn clean sonar:sonar'
                }
            }
        }

        stage('Deploy app') {
            steps {
                sh "cd /ansible && ansible-playbook playbook.yml --extra-vars app_path=${env.WORKSPACE}"
            }
        }

    }

    post {
        always {
            echo 'Done'
        }
    }
}
```