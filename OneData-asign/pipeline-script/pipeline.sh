pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "######"
        DOCKERHUB_PASS = "######"

        IMAGE1 = "onedatas1i"
        IMAGE2 = "onedatas2i"
        IMAGE3 = "onedatas3i"

        CONTAINER1 = "onedatas1c"
        CONTAINER2 = "onedatas2c"
        CONTAINER3 = "onedatas3c"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/arun-s1337/One-data-assign.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {

                    // --- SERVICE 1 ---
                    sh """
                        cd OneData-asign/service_1
                        docker build -t ${DOCKERHUB_USER}/${IMAGE1}:latest .
                    """

                    // --- SERVICE 2 ---
                    sh """
                        cd OneData-asign/service_2
                        docker build -t ${DOCKERHUB_USER}/${IMAGE2}:latest .
                    """
                    // --- SERVICE 3 ---
                    sh """
                        cd OneData-asign/service_3
                        docker build -t ${DOCKERHUB_USER}/${IMAGE2}:latest .
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    sh """
                        echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                    """
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    sh """
                        docker push ${DOCKERHUB_USER}/${IMAGE1}:latest
                        docker push ${DOCKERHUB_USER}/${IMAGE2}:latest
                        docker push ${DOCKERHUB_USER}/${IMAGE3}:lates
                    """
                }
            }
        }

        stage('Run Containers on EC2') {
            steps {
                script {

                    // Stop old containers if running
                    sh """
                        docker rm -f ${CONTAINER1} || true
                        docker rm -f ${CONTAINER2} || true
                        docker rm -f ${CONTAINER3} || true
                    """

                    // Start service 1
                    sh """
                        docker run -d --name ${CONTAINER1} -p 8081:3000 \
                        ${DOCKERHUB_USER}/${IMAGE1}:latest
                    """

                    // Start service 2
                    sh """
                        docker run -d --name ${CONTAINER2} -p 8082:3000 \
                        ${DOCKERHUB_USER}/${IMAGE2}:latest
                    """
                    // Start service 3
                    sh """
                        docker run -d --name ${CONTAINER3} -p 8083:3000 \
                        ${DOCKERHUB_USER}/${IMAGE3}:latest
                    """
                }
            }
        }
    }
}
