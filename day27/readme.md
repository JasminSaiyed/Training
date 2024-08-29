Project Objective:
+ This project will test your ability to deploy a multi-tier architecture application using AWS CloudFormation. The deployment should include an EC2 instance, an S3 bucket, a MySQL DB instance in RDS, and a VPC, all within the specified constraints.
+ Project Overview:
You are required to design and deploy a multi-tier application using AWS CloudFormation. The architecture will include the following components:
+ EC2 Instance: Serve as the web server.
S3 Bucket: Store static assets or configuration files.
RDS MySQL DB Instance: Serve as the database backend.
VPC: Ensure secure communication between the components.
Specifications:
+ EC2 Instance: Use a t2.micro instance type, located in the public subnet, with SSH access allowed from a specific IP range.
RDS MySQL DB Instance: Use a t3.micro instance type, located in a private subnet.
+ S3 Bucket: Use for storing configuration files or assets for the web server.
VPC: Create a VPC with public and private subnets. No NAT Gateway or Elastic IP should be used. Internet access for the EC2 instance should be provided via an Internet Gateway attached to the VPC.
+ CloudFormation Template: Participants must create a CloudFormation template to automate the deployment process.
Allowed Regions: Deployment is restricted to the regions us-east-1, us-east-2, us-west-1, and us-west-2.
Key Tasks:
+ Create a CloudFormation Template:
VPC and Subnets:
Define a VPC with one public and one private subnet.
Attach an Internet Gateway to the VPC for public subnet access.
Security Groups:
Create a security group for the EC2 instance, allowing SSH and HTTP access from a specific IP range.
Create a security group for the RDS instance, allowing MySQL access from the EC2 instance only.
EC2 Instance:
Launch a t2.micro EC2 instance in the public subnet.
Configure the instance to access the S3 bucket and connect to the RDS instance.
S3 Bucket:
Create an S3 bucket for storing static assets or configuration files.
Ensure the EC2 instance has the necessary IAM role and permissions to access the S3 bucket.
RDS MySQL DB Instance:
Launch a t3.micro MySQL database in the private subnet.
Configure the security group to allow access only from the EC2 instance.
Deploy the Application:
Deploy the CloudFormation stack using the template created.
Verify that all components are correctly configured and operational.
Ensure the EC2 instance can communicate with the RDS instance and access the S3 bucket.

AWSTemplateFormatVersion: '2010-09-09'
Description: CloudFormation Template for Multi-Tier Architecture

Parameters:
  VPCName:
    Type: String
    Default: jasminVPC
  CIDR:
    Type: String
    Default: 10.0.0.0/16
  PublicSubnet1CIDR:
    Type: String
    Default: 10.0.1.0/24
  PrivateSubnet1CIDR:
    Type: String
    Default: 10.0.2.0/24
  PrivateSubnet2CIDR:
    Type: String
    Default: 10.0.3.0/24
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Name of an existing EC2 KeyPair to enable SSH access
    ConstraintDescription: Must be the name of an existing EC2 KeyPair

Resources:
  # VPC
  jasminVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref CIDR
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Ref VPCName

  # Internet Gateway
  jasminInternetGateway:
    Type: AWS::EC2::InternetGateway

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref jasminVPC
      InternetGatewayId: !Ref jasminInternetGateway

  # Public Subnet 1
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref jasminVPC
      CidrBlock: !Ref PublicSubnet1CIDR
      MapPublicIpOnLaunch: true
      AvailabilityZone: us-west-1a
# private Subnet 2
  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref jasminVPC
      CidrBlock: !Ref PrivateSubnet2CIDR
      MapPublicIpOnLaunch: false
      AvailabilityZone: us-west-1b

  # Private Subnet
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref jasminVPC
      CidrBlock: !Ref PrivateSubnet1CIDR
      AvailabilityZone: us-west-1a

  # Route Table for Public Subnet
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref jasminVPC

  PublicRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref jasminInternetGateway

  AssociatePublicSubnet:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet1
      RouteTableId: !Ref PublicRouteTable

  # EC2 Instance
  MyEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      KeyName: !Ref KeyName
      SubnetId: !Ref PublicSubnet1
      ImageId: ami-0fda60cefceeaa4d3
      SecurityGroupIds:
        - !Ref EC2SecurityGroup

  EC2SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable SSH access
      VpcId: !Ref jasminVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0

  # RDS MySQL Instance
  MyRDSInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceClass: db.t3.micro
      AllocatedStorage: 20
      Engine: MySQL
      MasterUsername: admin
      MasterUserPassword: Admin12345
      VPCSecurityGroups:
        - !Ref RDSSecurityGroup
      DBSubnetGroupName: !Ref RDSSubnetGroup
      MultiAZ: false
      PubliclyAccessible: false

  RDSSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: Subnets for RDS
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2

  RDSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for RDS
      VpcId: !Ref jasminVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref EC2SecurityGroup

  # S3 Bucket
  MyS3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: jasminsample-bucket
      AccessControl: Private

Outputs:
  WebsiteURL:
    Description: URL for the EC2 instance
    Value: !Sub http://${MyEC2Instance.PublicDnsName}


![img-1](<Screenshot from 2024-08-20 17-51-37.png>)
![img-2](<Screenshot from 2024-08-20 17-52-14.png>)
![img-3](<Screenshot from 2024-08-20 17-54-39.png>)
![img-4](<Screenshot from 2024-08-20 17-57-42.png>)
![img-5](<Screenshot from 2024-08-20 17-58-11.png>)
Testing:
Test the deployed application by accessing it via the EC2 instance's public IP or DNS.
Verify the connectivity between the EC2 instance and the RDS instance.
Confirm that the EC2 instance can read from and write to the S3 bucket.
Documentation:
Document the entire process, including the design decisions, the CloudFormation template, and the testing steps.
Include screenshots or logs demonstrating the successful deployment and testing of the application.
Resource Termination:
Once the deployment and testing are complete, terminate all resources by deleting the CloudFormation stack.
Ensure that no resources, such as EC2 instances, RDS instances, or S3 buckets, are left running.
![img-6](<Screenshot from 2024-08-20 18-21-43.png>)
![img-7](<Screenshot from 2024-08-20 18-22-22.png>)
![img-8](<Screenshot from 2024-08-20 18-23-45.png>)
![img-9](<Screenshot from 2024-08-20 18-24-57.png>)
![img-10](<Screenshot from 2024-08-20 18-26-10.png>)
![img-11](<Screenshot from 2024-08-20 18-26-10.png>)
![img-12](<Screenshot from 2024-08-20 18-26-33.png>)
![img-13](<Screenshot from 2024-08-20 18-27-52.png>)