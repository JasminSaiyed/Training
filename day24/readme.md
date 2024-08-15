 + Comprehensive AWS S3 Management and Static Website Hosting
Objective:
To test your knowledge and skills in managing AWS S3 storage classes, lifecycle management, bucket policies, access control lists (ACLs), and hosting a static website on S3. You will apply their understanding in a practical scenario, ensuring you have mastered the critical aspects of AWS S3.
- Project Scenario:
You are tasked with creating and managing an S3 bucket for a fictional company, "TechVista Inc.," that hosts a static website for displaying their product portfolio. The website will have different types of content, including high-resolution images, which require careful storage management to optimize costs. Additionally, the company has strict security requirements for accessing the content.
Project Steps and Deliverables:
- Create and Configure an S3 Bucket:
Create an S3 bucket named techvista-portfolio-[your-initials].
Enable versioning on the bucket.
Set up the bucket for static website hosting.
Upload the provided static website files (HTML, CSS, images).
Ensure the website is accessible via the S3 website URL.
![img-1](<Screenshot from 2024-08-13 18-11-58.png>)
![img-2](<Screenshot from 2024-08-13 15-44-10.png>)
![img-3](<Screenshot from 2024-08-13 15-44-17.png>)
[img-4](<Screenshot from 2024-08-13 16-11-08.png>)


Implement S3 Storage Classes:
Classify the uploaded content into different S3 storage classes (e.g., Standard, Intelligent-Tiering, Glacier).
Justify your choice of storage class for each type of content (e.g., HTML/CSS files vs. images).
![img-5](<Screenshot from 2024-08-13 16-18-35.png>)
![img-6](<Screenshot from 2024-08-13 16-19-03.png>)
Lifecycle Management:
Create a lifecycle policy that transitions older versions of objects to a more cost-effective storage class (e.g., Standard to Glacier).
Set up a policy to delete non-current versions of objects after 90 days.
Verify that the lifecycle rules are correctly applied.
![img-7](<Screenshot from 2024-08-13 16-22-22.png>)
Configure Bucket Policies and ACLs:
Create and attach a bucket policy that allows read access to everyone for the static website content.
Restrict access to the S3 management console for specific IAM users using the bucket policy.
Set up an ACL to allow a specific external user access to only a particular folder within the bucket.
Test and Validate the Configuration:
Test the static website URL to ensure it is accessible.
Validate the storage class transitions based on the lifecycle policy.
Check the effectiveness of the bucket policy and ACLs by simulating different access scenarios (e.g., accessing the content with an external user, denying access from unauthorized users).
![img-8](<Screenshot from 2024-08-13 16-45-49.png>)
Documentation and Report:
Document each step you performed, including the reasoning behind your choices for storage classes, lifecycle policies, bucket policies, and ACLs.
Provide screenshots of key configurations and test results.
Summarize the project in a brief report, highlighting any challenges faced and how they were resolved.
