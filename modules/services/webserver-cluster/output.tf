

output "elb_dns_name" {
    value=aws_elb.scalableec2-elb.dns_name
    description="The public DNS name of the ELB"
}
