
#
# A module to create our ec2 instances in a highly available autoscale group
#
data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "scalableec2" {
   image_id=var.instance_ami
   instance_type=var.instance_type
   security_groups=[aws_security_group.scalableec2-sg.id]
   user_data= <<-EOF
              #!/bin/bash
              echo ""
              echo "Hello from scalableec2">index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
   lifecycle {
     # if we change the launch configuration, it will replace the instances, not modify.
     # this specifies that we create the new launch config before deleting the old one, not vice versa
     create_before_destroy=true
   }
}

resource aws_security_group "scalableec2-sg" {
  name="scalableec2-security-group"
  ingress {
    from_port=var.server_port
    to_port=var.server_port
    protocol="tcp"
    # define the IPs that have access (all in this case) 
    cidr_blocks=["0.0.0.0/0"]
  }
   tags = { 
     Name=var.resource_name
     owner=var.org_owner
     createdby=var.profile
   }
}

resource "aws_autoscaling_group" "scalableec2-asg" {
  launch_configuration=aws_launch_configuration.scalableec2.id
  availability_zones=data.aws_availability_zones.all.names  
  min_size=var.min_scalable_instances
  max_size=var.max_scalable_instances

  load_balancers=[aws_elb.scalableec2-elb.name]
  # this tells the autoscaling group that healthcheck will be done by the ELB, not the default EC2 (done by the hypervisor) healthcheck.
  health_check_type="ELB"
  tag {
     key="Name"
     value=var.resource_name
     propagate_at_launch=true
  }
  tag {
     key="owner"
     value=var.org_owner
     propagate_at_launch=true
  }
}

# create a classic elastic load balancer for this test. 
resource "aws_elb" "scalableec2-elb" {
  name = "scalableec2-elb"
  availability_zones=data.aws_availability_zones.all.names
  security_groups=[aws_security_group.scalableec2-elb-sg.id]

  # define listeners to route requests to our ec2 instances.
  listener {
    lb_port=var.elb_port
    lb_protocol="http"
    instance_port=var.server_port
    instance_protocol="http"
  }
    # Configure a health check on the instances from the ELB so it knows where to route
  health_check {
       # hits the "/" URL on each instance being balanced.
       target="HTTP:${var.server_port}/"
       interval=30
       timeout=3
       healthy_threshold=2
       unhealthy_threshold=2
  }
  tags = { 
    Name=var.resource_name
    owner=var.org_owner
    createdby=var.profile
  }
}

resource "aws_security_group" "scalableec2-elb-sg" {
    name="scalableec2-elb-eg"
     # allow access from anywhere on port 80 of the elb
    ingress {
      from_port=80
      to_port=80
      protocol="tcp"
      cidr_blocks=["0.0.0.0/0"]
    }
    # allow outbound any protocol from ec2 instances to anywhere.
    egress {
      from_port=0
      to_port=0
      protocol="-1"
      cidr_blocks=["0.0.0.0/0"]
    }
   tags = { 
    Name=var.resource_name
    owner=var.org_owner
    createdby=var.profile
  }
}
