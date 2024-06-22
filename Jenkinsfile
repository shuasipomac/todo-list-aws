pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        STACK_NAME = 'staging-todo-list-aws'
        S3_BUCKET = 'aws-sam-cli-managed-default-samclisourcebucket-cxher468fqlw'
        S3_PREFIX = 'staging'
        STAGE = 'staging'
    }

    stages {
        stage('Get Code') {
            steps {
                echo 'Inicio de la clonación del código fuente!!!'
                git branch: 'develop', url: 'https://github.com/shuasipomac/todo-list-aws.git'
            }
        }

    
        stage('Static Code'){
                    steps{
                        sh """
                            echo 'Host name, User and Workspace'
                            hostname
                            whoami
                            pwd
                        """
                        
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            //sh "python -m flake8 --exit-zero --format=pylint src >flake8.out"
                            sh "flake8 \
                                    --exit-zero \
                                    --format=pylint \
                                    --max-line-length=100 \
                                    src > flake8.out"
                            
                            recordIssues(
                                tools: [flake8(name: 'Flake8', pattern: 'flake8.out')],
                                qualityGates: [
                                    [threshold: 9999, type: 'TOTAL', unstable: false],
                                    [threshold: 9999, type: 'TOTAL', unstable: true]
                                ]
                            )
                        }
                    }
        }    

    
       
       stage('Security code'){
           steps{
               catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                  sh "pwd"
                  sh "whoami"
                  
                  sh "bandit --exit-zero -r src -f custom -o bandit.out --severity-level medium --msg-template '{abspath}:{line}: {severity}: {test_id}: {msg}'"
                    recordIssues tools: [pylint(name: 'Bandit', pattern: 'bandit.out')], qualityGates: [[threshold: 90, type: 'TOTAL', unstable: true], [threshold: 100, type: 'TOTAL', unstable: false]]
 
               }
            }
        }


        stage('Deploy'){
            steps{
                sh """
                    echo 'Host name:'; hostname
                    echo 'User:'; whoami
                    echo 'Workspace:'; pwd
                """

                //sam build command
                sh "sam build"

                sleep(time: 1, unit: 'SECONDS')

                //sam deploy command
                sh "sam deploy \
                        --template-file template.yaml \
                        --stack-name ${env.STACK_NAME} \
                        --region ${env.AWS_REGION} \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=${env.STAGE} \
                        --no-fail-on-empty-changeset \
                        --s3-bucket ${env.S3_BUCKET} \
                        --s3-prefix ${env.S3_PREFIX} \
                        --no-confirm-changeset"
            }
        }


    stage('Extract stack outputs') {
            //env variables for output endpoint from sam deploy command
            environment {
                ENDPOINT_BASE_URL_API = 'init'
            }
            steps {
                sh """
                    echo 'Host name:'; hostname
                    echo 'User:'; whoami
                    echo 'Workspace:'; pwd
                """

                echo "Value for --> STAGE: ${env.STAGE}"
                echo "Value for --> AWS_REGION: ${env.AWS_REGION}"

                script {
                    //asign permissions to execut scripts
                    sh "chmod +x obtiene_base_url_api.sh"

                    //execute extract_output.sh script for extract outputs url's from sam deploy command
                    sh "./obtiene_base_url_api.sh ${env.STAGE} ${env.AWS_REGION}"

                    //list temporal files created with url's for all endpoint
                    sh "ls -l *.tmp"

                    //read temporal files and asing the value to environment variable
                    def base_url = readFile('base_url_api.tmp').trim()
                    env.ENDPOINT_BASE_URL_API = "${base_url}"
                                
                    //clean temporal files
                    sh "rm *.tmp"
                }
            }
        }

        stage('Integration tests') {
            steps {
                sh """
                    echo 'Host name:'; hostname
                    echo 'User:'; whoami
                    echo 'Workspace:'; pwd
                """

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        export BASE_URL=${env.ENDPOINT_BASE_URL_API}
                        /usr/local/bin/pytest --junitxml=result-rest.xml test/integration/todoApiTest.py
                    """
                }
            }
        }














        
    }
}
