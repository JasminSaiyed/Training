Assessment Project: End-to-End Deployment and Management of a Scalable E-Commerce Platform on AWS
Objective:

To evaluate your proficiency in designing, deploying, and managing a comprehensive and scalable e-commerce platform on AWS. The project will integrate multiple AWS services, including S3, EC2, Auto Scaling, Load Balancer, VPC (without NAT Gateway), and RDS. The platform must be highly available, secure, and optimized for performance.

Project Scenario:

You are tasked with deploying a scalable e-commerce platform for "ShopMax," an online retailer preparing for a major sales event. The platform needs to handle fluctuating web traffic, securely manage user and product data, and serve both dynamic and static content efficiently. The infrastructure should be cost-effective and secure, with high availability and fault tolerance.

Project Steps and Deliverables:
1. VPC Design and Implementation:
Design a Custom VPC:
Create a VPC with four subnets: two public subnets (for EC2 instances and Load Balancers) and two private subnets (for RDS and backend services).
![img-1](<Screenshot from 2024-08-17 14-50-06.png>)
![img-2](<Screenshot from 2024-08-17 14-50-15.png>)\
create 4 subnets 
2 public 
2 private
![img-3](<Screenshot from 2024-08-17 15-02-41.png>)
create routetable
1 private
2 public
![img-4](<Screenshot from 2024-08-17 15-10-47.png>)
![img-5](<Screenshot from 2024-08-17 15-10-52.png>)
create ec2 
![img-6](<Screenshot from 2024-08-17 16-20-53.png>)
![img-7](<Screenshot from 2024-08-17 16-20-57.png>)
![img-8](<Screenshot from 2024-08-17 16-21-09.png>)
![img-9](<Screenshot from 2024-08-17 16-32-57.png>)
![img-10](<Screenshot from 2024-08-17 16-15-31.png>)
![img-11](<Screenshot from 2024-08-17 16-23-04.png>)
create security group
![img-12](<Screenshot from 2024-08-17 16-53-31.png>)
![img-13](<Screenshot from 2024-08-17 16-38-11.png>)