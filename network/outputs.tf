output "vpc_id" {
  description = "VPC ID. CFN export: routebox-<env>-vpc-id."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block. CFN export: routebox-<env>-vpc-cidr."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of 3 public subnet IDs in AZ order (a, b, c)."
  value = [
    aws_subnet.public["a"].id,
    aws_subnet.public["b"].id,
    aws_subnet.public["c"].id,
  ]
}

output "private_subnet_ids" {
  description = "List of 3 private subnet IDs in AZ order (a, b, c)."
  value = [
    aws_subnet.private["a"].id,
    aws_subnet.private["b"].id,
    aws_subnet.private["c"].id,
  ]
}

# Individual subnet IDs for parity with CFN exports (routebox-<env>-public-subnet-{1,2,3}).

output "public_subnet_1_id" {
  description = "Public subnet A (AZ index 0). CFN export: routebox-<env>-public-subnet-1."
  value       = aws_subnet.public["a"].id
}

output "public_subnet_2_id" {
  description = "Public subnet B (AZ index 1). CFN export: routebox-<env>-public-subnet-2."
  value       = aws_subnet.public["b"].id
}

output "public_subnet_3_id" {
  description = "Public subnet C (AZ index 2). CFN export: routebox-<env>-public-subnet-3."
  value       = aws_subnet.public["c"].id
}

output "private_subnet_1_id" {
  description = "Private subnet A (AZ index 0). CFN export: routebox-<env>-private-subnet-1."
  value       = aws_subnet.private["a"].id
}

output "private_subnet_2_id" {
  description = "Private subnet B (AZ index 1). CFN export: routebox-<env>-private-subnet-2."
  value       = aws_subnet.private["b"].id
}

output "private_subnet_3_id" {
  description = "Private subnet C (AZ index 2). CFN export: routebox-<env>-private-subnet-3."
  value       = aws_subnet.private["c"].id
}

output "alb_security_group_id" {
  description = "ALB security group ID. CFN export: routebox-<env>-alb-sg-id."
  value       = aws_security_group.alb.id
}

output "ecs_service_security_group_id" {
  description = "ECS service security group ID. CFN export: routebox-<env>-ecs-sg-id."
  value       = aws_security_group.ecs_service.id
}

output "rds_security_group_id" {
  description = "RDS security group ID. CFN export: routebox-<env>-rds-sg-id."
  value       = aws_security_group.rds.id
}

output "jenkins_security_group_id" {
  description = "Jenkins security group ID. CFN export: routebox-<env>-jenkins-sg-id."
  value       = aws_security_group.jenkins.id
}
