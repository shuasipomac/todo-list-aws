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


    stage('Extrae Stack') {
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

        stage('Rest Tests') {
            steps {
                sh """
                    echo 'Host name:'; hostname
                    echo 'User:'; whoami
                    echo 'Workspace:'; pwd
                """

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                   sh """
                        echo "variable ${env.ENDPOINT_BASE_URL_API}"
                        export BASE_URL=${env.ENDPOINT_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py
                    """
                     junit 'result*.xml'
                }
            }
        }


      stage('Promote') {
           
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    withCredentials([string(credentialsId: 'MiTokenDeGitHub', variable: 'PAT')]) {
                        sh """
                            echo 'STAGE --> Promote merge to master'
                            echo 'Host name:'; hostname
                            echo 'User:'; whoami
                            echo 'Workspace:'; pwd
                        """

                        script {
                            // Configuración de git
                            sh "git config --global user.email 'shuasipomac.devops@gmail.com'"
                            sh "git config --global user.name 'shuasipomac'"

                            //Eliminar cualquier cambio en el directorio de trabajo
                            sh "git checkout -- ."

                            //Hacer checkout a master y obtener la última versión desde el origen
                            sh "git checkout master"
                            sh "git pull https://\$PAT@github.com/shuasipomac/todo-list-aws.git  master"
                                                                                 
                            //Hacer checkout a develop y obtener la última versión desde el origen
                            sh "git checkout develop"
                            sh "git pull https://\$PAT@github.com/shuasipomac/todo-list-aws.git  develop"
                                                    
                            //Checkout master
                            sh "git checkout master"

                            //Merge develop en master
                            def mergeStatus = sh(script: "git merge develop", returnStatus: true)

                            //En caso de conflicto en el Merge o si dió Error el Merge
                            if (mergeStatus){
                                //Mensaje de error para conflicto o error en la ejecución del merge
                                sh "echo 'Error: Merge conflict or other error occurred during git merge.'"
                                //Abort merge
                                sh "git merge --abort"

                                //Lanzar el merge nuevamente y mantener los archivos en master en caso de conflicto
                                sh "git merge develop -X ours --no-commit"
                                //Restaurar el archivo Jenkinsfile con la versión del master
                                sh "git checkout --ours Jenkinsfile"
                                sh "git add Jenkinsfile"
                                sh "git commit -m 'Merged develop into master, excluding Jenkinsfile'"
                            }
                            else {
                                sh "echo 'Merge completed successfully.'"
                            }
                            
                            //Push del resultado del merge result a master
                            sh "git push https://\$PAT@github.com/shuasipomac/todo-list-aws.git master"
                                                    
                        }
                    }
                }
            }
        }





        
    }
}
