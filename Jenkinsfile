pipeline {
    agent any

    stages {
        stage('Build_Ubuntu_image_with_CMake') {
            steps {
                build 'Build_Ubuntu_image_with_CMake'
            }
        }
        stage('Build_CMake_Image') {
            steps {
                build 'Build_CMake_Image'
            }
        }
    }

}