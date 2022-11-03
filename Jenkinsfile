pipeline {
	agent any
	tools {
		maven 'maven-3.6.2'
		jdk 'jdk-8'
		terraform 'terraform-1.3.2'
	}
	options {
		buildDiscarder(logRotator(numToKeepStr: '5'))
		gitLabConnection gitLabConnection: 'gitlab-dawid'
	}

	triggers {
        gitlab(
            triggerOnPush: true,
            branchFilterType: 'All'
        )
		cron 'H/15 * * * *'
	}
	
	environment {
        COMMIT_MSG = sh (script: "git log -1 | grep 'test'", returnStatus: true)
    }

	stages {

		stage('Terraform Environments') {
			steps {
				echo env.BUILD_USER
				dir('./terraform') {
					script {
						ACT_ENV = sh(script: "terraform workspace list", returnStdout: true).trim()
						emailext body: "${ACT_ENV}", subject: 'Active environments', to: 'dawidtomczynski@gmail.com'
						try {
							AGE = sh(script: "find ./terraform.tfstate.d/test/terraform.tfstate -mmin +15 | grep \".*\"", returnStatus: true)
							if (AGE == 0) {
								sh """
									terraform workspace select test
									terraform destroy -auto-approve -var-file='test.tfvars'
									terraform workspace select default
									terraform workspace delete test
								"""
								emailext body: "Old test environment deleted.", subject: 'Deleted environment', to: 'dawidtomczynski@gmail.com'
							} 
						} catch (err) {
							echo 'no test environment'
						}
					}
				}
			}
		}

		stage('Compile') {
			when { expression { env.BUILD_USER != 'Timer Trigger' }}
			steps {
				dir('./app') {
                    sh 'mvn clean compile'
				}
			}
		}

		stage('Unit Tests') {
			when { expression { env.BUILD_USER != 'Timer Trigger' }}
			steps {
				dir('./app') {
                    sh 'mvn clean test'
				}
			}
		}

		stage('Build') {
			when { expression { env.BUILD_USER != 'Timer Trigger' }}
			steps {
				dir('./app') {
                    sh 'mvn clean verify'
				}
				sh 'docker save -o ted-search.tar 644435390668.dkr.ecr.eu-central-1.amazonaws.com/dawid-ted-search:latest'
			}
		}
		
		stage('E2E Tests') {
			when { expression { (env.COMMIT_MSG == '0' && env.BUILD_USER != 'Timer Trigger') }}
			steps {
				dir('./terraform') {	
					sh 'terraform init'
					script {
						try {
							sh """
								terraform workspace new test
								terraform apply -auto-approve -var-file='test.tfvars'
							"""
						} catch (err) {
							sh """
								terraform workspace select test
								terraform apply -auto-approve -var-file='test.tfvars'
							"""
						}
					}
					sleep 10		
					script 	{
						EC2_IP = sh(script: "terraform output | cut -d ' ' -f3", returnStdout: true).trim()
						sh "curl $EC2_IP"
					}	
				}
			}
		}

		stage('Deploy') {
			when { expression { (env.COMMIT_MSG == '0' && env.BUILD_USER != 'Timer Trigger') }}
			steps {				
				sh """
					aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-central-1.amazonaws.com/dawid-ted-search
					docker push 644435390668.dkr.ecr.eu-central-1.amazonaws.com/dawid-ted-search:latest
				"""
				dir('./terraform') {
					script {
						try {
							sh """
								terraform workspace select prod
								terraform apply -replace=aws_instance.dawid-ted -auto-approve -var-file='prod.tfvars'
							"""
						} catch (err) {
							sh """
								terraform workspace new prod
								terraform apply -auto-approve -var-file='prod.tfvars'
							"""
						}
					}
				}	
			}
		}
	}

	post {
		success {
			script{
				if ( env.BUILD_USER != 'Timer Trigger' ) {
					emailext body: "You're the man!", subject: 'Job succeded', to: 'dawidtomczynski@gmail.com'
				}
			}
  		}
		failure {
			script {
				if ( env.BUILD_USER != 'Timer Trigger' ) {
					emailext body: 'Try harder.', subject: 'Job failed', to: 'dawidtomczynski@gmail.com'
				}
			}
		}
		cleanup {
			script {
				try {
					sh """
						rm -r app ted-search.tar
						docker rmi 644435390668.dkr.ecr.eu-central-1.amazonaws.com/dawid-ted-search:latest
					"""
				} catch (err) {
					echo 'nothing to clean'
				}
			}
		}
	}
}

