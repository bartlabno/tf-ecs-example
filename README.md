# Simple frontend-backend app
Here is an example of how easily can be deployed application with frontend, backend and mongodb to the AWS. 

## Purpose
One of the potential companies asked me to create proof of concept to improve theirs deployment prcess

## Frontend
This is simple React application which can easily be scalable. I prepared and pushed docker image previously into [istrald/react](https://hub.docker.com/r/istrald/react) repository

## Backend
This is simple JS backend API which I slightly modified to use mongodb from environment variable instead of hardcoded line followed by another image which I built and pushed to [istrald/react-backend](https://hub.docker.com/r/istrald/react-backend)

## Structure
This simple template creates ECS Cluster which hosts two services - frontend and backend. In front of both services there is Load Balancer created. Frontend has public ALB, backend internal. Additionally, there is DocumentDB created to host MongoDB. Other services created: VPC, Security Groups, Subnets and AWS Secrets (for database username and password)

## Limitations
This is initial release, and this is to show ideas on how React<->JS<->MongoDB application might be hosted. That said this is base for further improvements and might be used in real life scenario. Although some aspects must have be taken into consideration: better security using IAM policies, KMS encryption, more strict security groups, etc. Additionally this setup does not support creation of Route53 hosted zones nor certificates or many other services which might be involved into sealing this deployment

## Deployment
You can use terraform directly or terragrunt from `dev` folder. Terraform does not include backend and you will need to use `-var-file=dev.tfvars` to deploy. This will create state file locally. Highly not recommended. Alternatively use terragrunt. To achieve that modify [dev/terragrunt.hcl](dev/terragrunt.hcl) and change backend's S3.

## Credits
Source code of simple app thanks to the  https://github.com/knaopel/docker-frontend-backend-db/tree/master
Terraform templates [@bartlabno](mailto:labno.b@gmail.com)
