pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        STACK_NAME = 'todo-list-aws-production'
        S3_BUCKET = 'aws-sam-cli-managed-default-samclisourcebucket-cxher468fqlw'
        S3_PREFIX = 'todo-list-aws'
        STAGE = 'production'
    }

    stages {
        stage('Get Code') {
          steps {
                echo 'Inicio de la clonación del código fuente!!!'
                git branch: 'master', url: 'https://github.com/shuasipomac/todo-list-aws.git'
            }
        }

        stage('SAM Deploy'){
            steps{
                sh """
                    echo 'Host name:'; hostname
                    echo 'User:'; whoami
                    echo 'Workspace:'; pwd
                """

                //sam build command
                sh "sam build"

                sleep(time: 1, unit: 'SECONDS')

              //  sam deploy command
                  sh "sam deploy \
                      --region ${env.AWS_REGION} \
                      --config-env ${env.STAGE} \
                      --template-file template.yaml \
                      --config-file samconfig.toml \
                      --no-fail-on-empty-changeset \
                      --no-confirm-changeset"
                
                 //   sh "sam deploy \
                 //           --template-file template.yaml \
                 //           --stack-name ${env.STACK_NAME} \
                 //           --region ${env.AWS_REGION} \
                 //           --capabilities CAPABILITY_IAM \
                 //           --parameter-overrides Stage=${env.STAGE} \
                 //           --no-fail-on-empty-changeset \
                 //           --s3-bucket ${env.S3_BUCKET} \
                 //           --s3-prefix ${env.S3_PREFIX} \
                 //           --no-confirm-changeset"
            }
        }

    stage('Extrae Stack') {
            //env variables for output endpoint from sam deploy command
            environment {
                ENDPOINT_BASE_URL_API = 'init'
            }
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
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
        }

        stage('Rest Tests') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        echo 'Host name:'; hostname
                        echo 'User:'; whoami
                        echo 'Workspace:'; pwd
                    """
                
                   sh """
                        echo "variable ${env.ENDPOINT_BASE_URL_API}"
                        export BASE_URL=${env.ENDPOINT_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py -m pruebashumo
                    """
                     junit 'result*.xml'
                }
            }
        }

        
    }
}
