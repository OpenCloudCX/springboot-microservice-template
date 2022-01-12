pipeline {
  agent {
    kubernetes {
      yaml '''
      metadata:
        replicas: 1
        template:
          metadata:
            labels:
              app: master
          spec:
            securityContext:
              runAsUser: jenkins
      spec:
        containers:
          - name: java-builder
            image: maven
            command:
              - sleep
            args:
              - 99d
      '''
    }
  }
  environment {
    GROUP = "odos"
    PROJECT = "spring-microservice"
    CURR_COMMIT_MSG = sh(
      returnStdout: true, script: 'git log --format=%B -n 1 HEAD'
    ).trim()
    APP_VERSION = "1.0.0" # readMavenPom().getVersion()
    IS_JOB_INCREMENT = CURR_COMMIT_MSG.equals('v' + APP_VERSION)
    ITERATION_TYPE = setVersionIteration(CURR_COMMIT_MSG)
    CI = true
  }
  stages {
    stage('Checkout') {
        steps {
            git branch: 'main', url: 'https://github.com/ODOS-Technical-Challenge/springboot-microservice-template.git'
        }   
    }
    stage('Install Dependencies') {
      steps {
        container('java-builder') {
          script {
              sh 'mvn compile dependency:copy-dependencies -DincludeScope=test'
              sh 'mv target/dependency target/test-dependency'
              sh 'mvn compile dependency:copy-dependencies -DincludeScope=runtime'
            }
          
        }
      }
    }
    stage('Unit Testing') {
      steps {
        container('java-builder') {
          script {
              sh 'mvn test jacoco:report'
          }
        }
      }
    }
    stage('Build App') {
      steps {
        container('java-builder') {
          script {
              sh 'mvn -DskipTests -DskipITs package'
          }
        }
      }
    }
    stage('Sonarqube Code Scan') {
      options {
        timeout(time: 1, unit: 'HOURS')
      }
      steps {
        container('java-builder') {
          script {
            try {
              scannerHome = tool 'sonarqube'
              branchName = env.BRANCH_NAME.replace(/\//, '-')
              projectKey = env.PROJECT
              mainBranch = branchName
              version = env.APP_VERSION
              if (env.BRANCH_NAME.startsWith('PR-')) {
                version = "${version} (${branchName})"
              }
              withSonarQubeEnv("sonarqube") {
                sh "${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectName=\"${projectKey}: (${mainBranch})\" \
                -Dsonar.projectVersion=\"${version}\" \
                -Dsonar.projectKey=${projectKey}:${mainBranch} \
                -Dsonar.java.binaries=target/classes \
                -Dsonar.java.libraries=target/dependency/*.jar \
                -Dsonar.java.test.binaries=target/test-classes \
                -Dsonar.java.test.libraries=target/test-dependency/*.jar"
              }
            } catch (err) {
              echo err.getMessage()
            }
            echo currentBuild.result
          }
        }
      }
    }
    stage('Sonarqube Quality Gate') {
      options {
        timeout(time: 1, unit: 'MINUTES')
        retry(3)
      }
      steps {
        container('java-builder') {
          script {
            try {
              qg = waitForQualityGate()
              if (qg.status != 'OK') {
                error "Pipeline aborted due to quality gate failure: ${qg.status}"
              }
            } catch (err) {
              echo err.getMessage()
              error "Pipeline aborted due to quality gate failure: ${err.getMessage()}"
            }
            echo currentBuild.result
          }
        }
      }
    }
  }
  post {
    cleanup {
      deleteDir()
    }
  }
}

@NonCPS
def setVersionIteration(commitMsg) {
  def msg = commitMsg.toLowerCase()
  if (msg.contains('bugfix/') || msg.contains('hotfix/')) {
    return 'patch'
  }
  return 'minor'
}
