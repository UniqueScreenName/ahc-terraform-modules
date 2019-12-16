

output "elb_dns_name" {
    value=aws_elb.scalableec2-elb.dns_name
    description="The public DNS name of the ELB"
}

output "asg_name" {
    value=aws_autoscaling_group.scalableec2-asg.name
    description="The name of the autoscaling group"
}
