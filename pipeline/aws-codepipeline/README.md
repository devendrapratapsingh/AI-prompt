# AWS CodePipeline - Complete Enterprise-Grade CI/CD Guide

## Overview

AWS CodePipeline is a fully managed continuous delivery service that helps automate release pipelines for fast and reliable application and infrastructure updates. It integrates with AWS CodeBuild, CodeDeploy, Lambda, and third-party tools to create end-to-end CI/CD workflows.

### Key Capabilities
- **Fully Managed Service**: No infrastructure to manage
- **Multi-Stage Pipelines**: Build, test, deploy stages with approval gates
- **AWS Service Integration**: CodeBuild, CodeDeploy, CloudFormation, AppConfig, ServiceCatalog
- **Third-Party Integration**: GitHub, GitLab, Bitbucket, Jenkins, SonarQube, Slack
- **Artifact Management**: S3-based artifact storage with automatic cleanup
- **Deployment Strategies**: Blue/green, canary, rolling deployments
- **Infrastructure as Code**: Define pipelines with CloudFormation or CDK
- **Change Detection**: Automatic pipeline triggers on code changes
- **Approval Gates**: Manual approvals with SNS notifications
- **Retry Logic**: Automatic retry for transient failures
- **Cost Optimization**: Pay per active pipeline, no minimum fees

## Prerequisites

- AWS Account with appropriate IAM permissions
- Source repository (GitHub, AWS CodeCommit, BitBucket, or GitLab)
- AWS CLI configured with credentials
- Basic understanding of YAML/JSON

## System Requirements

### AWS Services
- **CodePipeline**: Fully managed (no infrastructure needed)
- **CodeBuild**: Managed build service (Docker-based)
- **CodeDeploy**: Supports on-premises, EC2, Lambda deployment targets
- **IAM**: Service roles for cross-service permissions
- **S3**: Artifact bucket (auto-created or existing)

### Local Development
- AWS CLI v2
- AWS SAM CLI (for local testing)
- Docker (for CodeBuild simulation)

## Installation & Setup

### Step 1: Create IAM Roles

```bash
# CodePipeline service role
aws iam create-role \
  --role-name CodePipelineServiceRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "codepipeline.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# CodeBuild service role
aws iam create-role \
  --role-name CodeBuildServiceRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "codebuild.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'
```

### Step 2: Create CodeBuild Project

```bash
aws codebuild create-project \
  --name my-build-project \
  --source type=GITHUB,location=https://github.com/myorg/myrepo.git \
  --artifacts type=S3,location=my-artifact-bucket \
  --environment type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL \
  --service-role arn:aws:iam::ACCOUNT:role/CodeBuildServiceRole
```

### Step 3: Create Pipeline via CloudFormation

```bash
aws cloudformation create-stack \
  --stack-name my-pipeline \
  --template-body file://pipeline.yaml \
  --parameters ParameterKey=GitHubToken,ParameterValue=YOUR_TOKEN \
  --capabilities CAPABILITY_NAMED_IAM
```

### Step 4: Enable Pipeline Notifications

```bash
# Create SNS topic
aws sns create-topic --name pipeline-notifications

# Subscribe to notifications
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT:pipeline-notifications \
  --protocol email \
  --notification-endpoint your-email@example.com
```

## Configuration Walkthrough

### buildspec.yml - Build Configuration

```yaml
version: 0.2

# Environment variables
env:
  variables:
    AWS_ACCOUNT_ID: "123456789012"
    AWS_DEFAULT_REGION: "us-east-1"
  parameter-store:
    DB_PASSWORD: /myapp/db/password
  secrets-manager:
    DOCKER_PASSWORD: dockerhub:password
  
cache:
  paths:
    - 'node_modules/**/*'

phases:
  pre_build:
    commands:
      - echo "Logging in to Amazon ECR..."
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - REPO_NAME=$(echo $CODEBUILD_SOURCE_REPO_URL | sed 's/.*\///')
      - IMAGE_REPO_NAME=${REPO_NAME%.git}
      - IMAGE_TAG="${CODEBUILD_RESOLVED_SOURCE_VERSION}"
      - npm ci --prefer-offline

  build:
    commands:
      - echo "Building application on `date`"
      - npm run build
      - echo "Running tests..."
      - npm run test -- --coverage
      - echo "Building Docker image..."
      - docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:latest

  post_build:
    commands:
      - echo "Pushing Docker image..."
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:latest
      - echo "Creating image definition file..."
      - printf '[{"name":"myapp","imageUri":"%s"}]' $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json
    - '**/*'
  name: BuildArtifact

reports:
  test-report:
    files:
      - 'coverage/cobertura-coverage.xml'
    file-format: 'COBERTURAXML'
  
  jest-report:
    files:
      - 'test-results.xml'
    file-format: 'JUNITXML'

cache:
  paths:
    - 'node_modules/**/*'
    - '.npm/**/*'
```

## CI/CD Pipeline Stages

### Pipeline Definition (CloudFormation)

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS CodePipeline for application'

Parameters:
  GitHubToken:
    Type: String
    NoEcho: true
  GitHubRepo:
    Type: String
    Default: myrepo
  GitHubBranch:
    Type: String
    Default: main

Resources:
  # S3 bucket for artifacts
  ArtifactBucket:
    Type: AWS::S3::Bucket
    Properties:
      VersioningConfiguration:
        Status: Enabled
      LifecycleConfiguration:
        Rules:
          - Id: DeleteOldArtifacts
            Status: Enabled
            ExpirationInDays: 30
            NoncurrentVersionExpirationInDays: 7

  # CodeBuild Project for Build Stage
  BuildProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub '${AWS::StackName}-build'
      ServiceRole: !GetAtt CodeBuildRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_SMALL
        Image: aws/codebuild/standard:7.0
        EnvironmentVariables:
          - Name: AWS_ACCOUNT_ID
            Value: !Ref AWS::AccountId
          - Name: AWS_DEFAULT_REGION
            Value: !Ref AWS::Region
      Source:
        Type: CODEPIPELINE
        BuildSpec: buildspec.yml
      LogsConfig:
        CloudWatchLogs:
          Status: ENABLED
          GroupName: !Sub '/aws/codebuild/${AWS::StackName}'

  # CodeBuild Project for Tests
  TestProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub '${AWS::StackName}-test'
      ServiceRole: !GetAtt CodeBuildRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_SMALL
        Image: aws/codebuild/standard:7.0
      Source:
        Type: CODEPIPELINE
        BuildSpec: |
          version: 0.2
          phases:
            install:
              commands:
                - npm ci
            build:
              commands:
                - npm run test -- --coverage
          artifacts:
            files:
              - coverage/**/*
          reports:
            test:
              files:
                - test-results.xml
              file-format: JUNITXML

  # CodePipeline
  Pipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      Name: !Sub '${AWS::StackName}-pipeline'
      RoleArn: !GetAtt CodePipelineRole.Arn
      ArtifactStore:
        Type: S3
        Location: !Ref ArtifactBucket
      Stages:
        # Source Stage
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: ThirdParty
                Provider: GitHub
                Version: '1'
              Configuration:
                Owner: myorg
                Repo: !Ref GitHubRepo
                Branch: !Ref GitHubBranch
                OAuthToken: !Ref GitHubToken
              OutputArtifacts:
                - Name: SourceOutput

        # Build Stage
        - Name: Build
          Actions:
            - Name: BuildAction
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref BuildProject
              InputArtifacts:
                - Name: SourceOutput
              OutputArtifacts:
                - Name: BuildOutput

        # Test Stage
        - Name: Test
          Actions:
            - Name: TestAction
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref TestProject
              InputArtifacts:
                - Name: BuildOutput
              OutputArtifacts:
                - Name: TestOutput

        # Manual Approval
        - Name: Approval
          Actions:
            - Name: ManualApproval
              ActionTypeId:
                Category: Approval
                Owner: AWS
                Provider: Manual
                Version: '1'
              Configuration:
                CustomData: "Review test results before deploying to production"

        # Deploy Stage
        - Name: Deploy
          Actions:
            - Name: DeployAction
              ActionTypeId:
                Category: Deploy
                Owner: AWS
                Provider: CloudFormation
                Version: '1'
              Configuration:
                ActionMode: CHANGE_SET_REPLACE
                StackName: !Sub '${AWS::StackName}-app-stack'
                ChangeSetName: !Sub '${AWS::StackName}-changeset'
                TemplatePath: 'BuildOutput::packaged.yaml'
                Capabilities: CAPABILITY_IAM,CAPABILITY_NAMED_IAM
              InputArtifacts:
                - Name: BuildOutput

  # IAM Roles
  CodePipelineRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: codepipeline.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AWSCodePipelineFullAccess
        - arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
        - arn:aws:iam::aws:policy/AWSCloudFormationFullAccess
        - arn:aws:iam::aws:policy/AmazonS3FullAccess
        - arn:aws:iam::aws:policy/IAMFullAccess

  CodeBuildRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: codebuild.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess
        - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
        - arn:aws:iam::aws:policy/AmazonS3FullAccess
        - arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
        - arn:aws:iam::aws:policy/SecretsManagerReadWrite

Outputs:
  PipelineName:
    Value: !Ref Pipeline
    Description: Pipeline name
  ArtifactBucketName:
    Value: !Ref ArtifactBucket
    Description: S3 artifact bucket
```

## Deployment Strategies

### Blue-Green Deployment

```yaml
Deploy:
  Type: AWS::CodeDeploy::DeploymentGroup
  Properties:
    ApplicationName: MyApp
    DeploymentGroupName: BlueGreenDeployment
    DeploymentConfigName: CodeDeployDefault.AllAtOnce
    DeploymentStyle:
      DeploymentType: BLUE_GREEN
      DeploymentOption: WITH_TRAFFIC_CONTROL
    BlueGreenDeploymentConfiguration:
      TerminateBlueInstancesOnDeploymentSuccess:
        Action: TERMINATE
        TerminationWaitTimeInMinutes: 5
      DeploymentReadyOption:
        ActionOnTimeout: CONTINUE_DEPLOYMENT
      GreenFleetProvisioningOption:
        Action: COPY_AUTO_SCALING_GROUP
```

### Canary Deployment

```yaml
DeploymentConfig:
  Type: AWS::CodeDeploy::DeploymentConfig
  Properties:
    MinimumHealthyHosts:
      Type: FLEET_PERCENT
      Value: 75
    TrafficRoutingConfig:
      Type: TimeBasedCanary
      TimeBasedCanary:
        CanaryPercentage: 10
        CanaryIntervalInMinutes: 5
```

## Monitoring and Notifications

```bash
# Create CloudWatch event for pipeline state changes
aws events put-rule \
  --name pipeline-state-change \
  --event-pattern '{"source":["aws.codepipeline"],"detail-type":["CodePipeline Pipeline Execution State Change"]}'

# Create SNS target
aws events put-targets \
  --rule pipeline-state-change \
  --targets "Id"="1","Arn"="arn:aws:sns:us-east-1:ACCOUNT:pipeline-notifications"
```

## Security Best Practices

### Secrets Management

```bash
# Store secrets in Secrets Manager
aws secretsmanager create-secret \
  --name myapp/prod/db-password \
  --secret-string "your-password"

# Reference in buildspec
env:
  secrets-manager:
    DB_PASSWORD: myapp/prod/db-password
```

### IAM Policy Least Privilege

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:PutJobSuccessResult",
        "codepipeline:PutJobFailureResult"
      ],
      "Resource": "*"
    }
  ]
}
```

## Troubleshooting

### Pipeline Failures

```bash
# Check pipeline status
aws codepipeline get-pipeline-state --name my-pipeline

# View build logs
aws codebuild batch-get-builds --ids build-id

# View CloudWatch logs
aws logs tail /aws/codebuild/my-project --follow
```

### CodeBuild Issues

```bash
# Test buildspec locally
aws codebuild batch-build-identifiers \
  --project-source-version myrepo:main
```

## FAQ

**Q: How do I trigger pipeline on specific branches?**
A: Configure branch filters in Source stage.

**Q: Can I rerun a failed stage?**
A: Yes, use the Retry button in pipeline execution details.

**Q: How long are artifacts retained?**
A: Default 30 days, configurable via S3 lifecycle policies.

**Q: How do I skip stages in a pipeline?**
A: Add manual approval actions to control flow.

## Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [CodeBuild Reference](https://docs.aws.amazon.com/codebuild/latest/userguide/)
- [CodeDeploy Guide](https://docs.aws.amazon.com/codedeploy/)
- [CodePipeline Best Practices](https://docs.aws.amazon.com/codepipeline/latest/userguide/best-practices.html)
