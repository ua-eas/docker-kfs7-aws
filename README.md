University of Arizona Kuali Financials Docker Image
=======================================================

This repository is for the Kuali team's KFS image used for the UAccess Financials application.

### Description
This project defines an image used for the KFS Docker container.

### Requirements
This is based on a **java8tomcat8** tagged image from the _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/tomcat8_ AWS ECR repository. 

### Building With Jenkins
The build command we use is `docker build --build-arg DOCKER_REGISTRY=${DOCKER_REGISTRY} --build-arg BASE_IMAGE_TAG_DATE=${BASE_IMAGE_TAG_DATE} --build-arg KUALICO_TAG=${KUALICO_TAG} -t ${DOCKER_REPOSITORY_NAME} .`
* `$DOCKER_REGISTRY` is the location of the Docker image repository in AWS. The value will be a variable in our Jenkins job and defined as `397167497055.dkr.ecr.us-west-2.amazonaws.com`.
* `$BASE_IMAGE_TAG_DATE` corresponds to the creation date in a tag of the *java8tomcat8* Docker image.
* `$DOCKER_REPOSITORY_NAME` is the name of the AWS ECR repository, which is _kuali/kfs7_.
* `KUALICO_TAG` is the date of the merged KualiCo release for the version of the KFS code that will be included in this image. It is used in the overall image tag we construct, which also includes the _ua-release_ number, whether it is a release or a snapshot, and 1) date/timestamp if a daily build or 2) the Jira ticket number if this is for a prototype environment.

We then tag and push the image to AWS with commands similar to the following: 
```
docker tag ${DOCKER_REPOSITORY_NAME}:latest ${DOCKER_REPOSITORY_URI}:${APP_TAG}
docker push ${DOCKER_REPOSITORY_URI}:${APP_TAG}
```

Examples of resulting tags:
- Daily/snapshot build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/kfs7:7.20170511-ua-release52-SNAPSHOT-20190502.071456-64_
- Prototype build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/kfs7:development-7.20170511-ua-release52-SNAPSHOT-FIN-863-_
- Release build: _397167497055.dkr.ecr.us-west-2.amazonaws.com/kuali/kfs7:7.20170511-ua-release51_

Jenkins link: https://kfs-jenkins.ua-uits-kuali-nonprod.arizona.edu/job/Development/

### Running A Container
The KFS Docker container is run on an EC2 instance in AWS. 

More information can be found on Confluence: https://confluence.arizona.edu/display/KAST/AWS+Environment+Basics.
