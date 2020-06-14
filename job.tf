provider "aws" {
  region  = "ap-south-1"
  profile = "akanksha"	
}

//security-group permissions
resource "aws_security_group" "mysg_allow_ssh_http" {
  name        = "aws_security_group"
  description = "gives ssh & http permissions to client"
  vpc_id      = "vpc-79978a11"

 ingress{
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 ingress{
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 egress{
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
    Name = "mysg_allow_ssh_http"
  }
}


//creating instance
resource "aws_instance" "myinstance" {
  ami               = "ami-052c08d70def0ac62"
  instance_type     = "t2.micro"
  key_name          = "key123"
  availability_zone = "ap-south-1a"
  security_groups   =  [ aws_security_group.mysg_allow_ssh_http.name ]
  
  
  connection {
    type        = "ssh"
	user        = "ec2-user"
	private_key = file("C:/Users/user/Downloads/key123.pem")
	host        = aws_instance.myinstance.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
	  "sudo yum install httpd php git -y" ,
	  "sudo systemctl restart httpd" ,
	  "sudo systemctl enable httpd" ,
	]
  }
  tags = {
    Name = "myinstance"
  }
}

//creating volume 
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = aws_instance.myinstance.availability_zone
  size              = 1
  tags = {
    Name = "ebs_volume"
  }
}
//attaching volume
resource "aws_volume_attachment" "ebs_attach" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.ebs_volume.id
  instance_id  = aws_instance.myinstance.id
  force_detach = true
}


//printing ip
output "myinstance_ip" {
  value = aws_instance.myinstance.public_ip
}
//printing port
output "web_port" {
  value = 80
}
//storing ip in a file 
resource "null_resource" "nulllocal"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.myinstance.public_ip} > publicip.txt"
  	}
}
//to priortise the terraform creation 
resource "null_resource" "nullremote"  {

depends_on = [
    aws_volume_attachment.ebs_attach,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/user/Downloads/key123.pem")
    host     = aws_instance.myinstance.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh" ,
      "sudo mount  /dev/xvdh  /var/www/html" ,
      "sudo rm -rf /var/www/html/*" ,
      "sudo git clone https://github.com/Uni-wv/terracode.git /var/www/html/" ,
    ]
  }
}

//to create s3 bucket 
resource "aws_s3_bucket" "test123akadb" {
  bucket = "test123akadb"
  acl = "private"
  region = "ap-south-1"
  
  tags = {
    Name = "test123akadb"
  }
}
  
locals {
    s3_origin_id = "myS3Origin"
  }

//to upload object to bucket
resource "aws_s3_bucket_object" "object" {
  depends_on = [
    aws_s3_bucket.test123akadb,
  ]
  bucket = "test123akadb"
  key = "my_bucket"
  source = "C:/Users/user/Desktop/html page/website/assets/web5.jpg"
}  
//to give policy of bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  depends_on = [
    aws_s3_bucket.test123akadb,
  ]
  bucket = "test123akadb"
  block_public_acls = false
  block_public_policy = false
}
//cloudfront distribution
resource "aws_cloudfront_distribution" "cloud_distribute" {
  origin {
    domain_name = aws_s3_bucket.test123akadb.bucket_regional_domain_name
	origin_id = local.s3_origin_id
  }
  enabled = true
  is_ipv6_enabled = true
  comment = "my cloud front access"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods = ["DELETE","PATCH","OPTIONS","POST","PUT","GET","HEAD"]
	cached_methods = ["GET","HEAD"]
	target_origin_id = local.s3_origin_id
	
	forwarded_values {
	  query_string = false 
	  cookies {
	    forward = "none"
	  }
	}
	min_ttl = 0
	default_ttl = 3600
	max_ttl = 86400
	compress = true
	viewer_protocol_policy = "redirect-to-https"
  }
  
  restrictions {
    geo_restriction {
	  restriction_type = "whitelist"
	  locations = ["US"]
	}
  }
  
  tags = {
    Environment = "production"
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
} 

resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote,
  ]

	provisioner "local-exec" {
	    command = "curl  ${aws_instance.myinstance.public_ip}"
  	}
}

