resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
  
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
  
}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myvpc.id
  
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id

}

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id

}

resource "aws_security_group" "mysg" {
    vpc_id = aws_vpc.myvpc.id

    ingress {
        description = "http port incoming traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH port incoming traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "web-sg"
    }
}

resource "aws_instance" "myec2" {
    ami = "ami-0dee22c13ea7a9a67"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = aws_subnet.sub1.id
    user_data = base64encode("user_data.sh")
   
}

resource "aws_instance" "myec21" {
    ami = "ami-0dee22c13ea7a9a67"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = aws_subnet.sub2.id
    user_data = base64encode("user_data1.sh")
   
}

resource "aws_s3_bucket" "example" {
    bucket = "akshabahagt1997"
  
}
resource "aws_s3_bucket_public_access_block" "example" {
    bucket = aws_s3_bucket.example.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false

  
}
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
    depends_on = [ 
        aws_s3_bucket_public_access_block.example,
        aws_s3_bucket_ownership_controls.example,
     ]
     bucket = aws_s3_bucket.example.id
     acl = "public-read"
  
}

resource "aws_lb" "mylb" {
    name = "myalb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.mysg.id]
    subnets = [aws_subnet.sub1.id, aws_subnet.sub2.id]

}

resource "aws_lb_target_group" "mytg" {
    port = 80
    name= "mytg"
    protocol = "HTTP"
    vpc_id = aws_vpc.myvpc.id

    health_check {
      path = "/"
      port = "traffic-port"

    }
  
}
resource "aws_alb_target_group_attachment" "mytgatt" {
    target_group_arn = aws_lb_target_group.mytg.arn
    target_id = aws_instance.myec21.id
    port = 80
  
}
resource "aws_alb_target_group_attachment" "mytgatt2" {
    target_group_arn = aws_lb_target_group.mytg.arn
    target_id = aws_instance.myec2.id
    port = 80
  
}

resource "aws_lb_listener" "mylist" {
    load_balancer_arn = aws_lb.mylb.arn
    port = 80
    protocol = "HTTP"
    default_action {
      target_group_arn = aws_lb_target_group.mytg.arn
      type = "forward"
    }

  
}

output "loadbalancerurl" {
    value = aws_lb.mylb.dns_name
  
}
