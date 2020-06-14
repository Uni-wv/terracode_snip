# terracode_snip
my terraform code and backup files. This code will create the following infrastucture in AWS cloud :- 

# 1
Create the key and security group which allow the port 80.
# 2
Launch EC2 instance.
# 3
In this Ec2 instance use the key and security group which i have created.
# 4
Launch one Volume (EBS) and mount that volume into /var/www/html
# 5
Copy the github repo website code (refer repository : terracode) into /var/www/html
# 6
Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.
# 7
Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html

# HOW TO RUN CODE ?
Steps:
1. Download the job.tf file and also download the latest terraform version from https://terraform.io. 
2. save terraform.exe file inside C:/users/user/programfile/terraform (in case of Windows OS) and set the path in "Environment Variable".
3. Now open "cmd" then run -> terraform init  => to download the required plugins for respective provider (in my case aws)
4. Optional* you might run -> terraform validate =>to validate the terraform code
5. Then run -> terraform apply -auto-approve =>to create the services and security groups in your AWS account

