# network module

Provisions the Routebox VPC network stack: one VPC, public and private subnets across three
AZs, an internet gateway, a single NAT gateway, route tables, and four default security groups.

This module is the Terraform equivalent of
`routebox-infra/cfn/network/template.yaml`. The port aims for full fidelity — read
the **Operational notes** section before applying.

## Resources created

| Resource | Terraform address |
|---|---|
| VPC | `aws_vpc.main` |
| Internet Gateway | `aws_internet_gateway.main` |
| Public subnets (×3) | `aws_subnet.public["a"/"b"/"c"]` |
| Private subnets (×3) | `aws_subnet.private["a"/"b"/"c"]` |
| Elastic IP for NAT | `aws_eip.nat` |
| NAT Gateway | `aws_nat_gateway.main` |
| Public route table | `aws_route_table.public` |
| Private route table | `aws_route_table.private` |
| Public default route (→ IGW) | `aws_route.public_default` |
| Private default route (→ NAT) | `aws_route.private_default` |
| Public RT associations (×3) | `aws_route_table_association.public["a"/"b"/"c"]` |
| Private RT associations (×3) | `aws_route_table_association.private["a"/"b"/"c"]` |
| ALB security group | `aws_security_group.alb` |
| ECS service security group | `aws_security_group.ecs_service` |
| RDS security group | `aws_security_group.rds` |
| Jenkins security group | `aws_security_group.jenkins` |
| RDS ingress from ECS | `aws_vpc_security_group_ingress_rule.rds_from_ecs` |
| RDS ingress from Jenkins | `aws_vpc_security_group_ingress_rule.rds_from_jenkins` |

## Inputs

| Name | Type | Description | Default |
|---|---|---|---|
| `environment` | `string` | Environment name: `dev`, `staging`, or `prod`. Validated. | required |
| `vpc_cidr` | `string` | VPC CIDR block (e.g. `10.10.0.0/16`). Validated pattern. | required |
| `public_subnet_cidrs` | `list(string)` | Exactly 3 CIDRs for public subnets (AZ a/b/c in order). | required |
| `private_subnet_cidrs` | `list(string)` | Exactly 3 CIDRs for private subnets (AZ a/b/c in order). | required |
| `cost_center` | `string` | Cost-allocation tag value (e.g. `platform-dev`). | `"platform"` |

## Outputs

| Name | Description | CFN export equivalent |
|---|---|---|
| `vpc_id` | VPC ID | `routebox-<env>-vpc-id` |
| `vpc_cidr_block` | VPC CIDR block | `routebox-<env>-vpc-cidr` |
| `public_subnet_ids` | List of 3 public subnet IDs (a, b, c) | — |
| `private_subnet_ids` | List of 3 private subnet IDs (a, b, c) | — |
| `public_subnet_1_id` | Public subnet A ID | `routebox-<env>-public-subnet-1` |
| `public_subnet_2_id` | Public subnet B ID | `routebox-<env>-public-subnet-2` |
| `public_subnet_3_id` | Public subnet C ID | `routebox-<env>-public-subnet-3` |
| `private_subnet_1_id` | Private subnet A ID | `routebox-<env>-private-subnet-1` |
| `private_subnet_2_id` | Private subnet B ID | `routebox-<env>-private-subnet-2` |
| `private_subnet_3_id` | Private subnet C ID | `routebox-<env>-private-subnet-3` |
| `alb_security_group_id` | ALB SG ID | `routebox-<env>-alb-sg-id` |
| `ecs_service_security_group_id` | ECS service SG ID | `routebox-<env>-ecs-sg-id` |
| `rds_security_group_id` | RDS SG ID | `routebox-<env>-rds-sg-id` |
| `jenkins_security_group_id` | Jenkins SG ID | `routebox-<env>-jenkins-sg-id` |

## Operational notes

### Single NAT gateway — intentional SPOF

The NAT gateway sits in public subnet A only. This is a deliberate cost trade-off.
Originally there were three NAT gateways (one per AZ); they were collapsed to one and
never restored. Private-subnet traffic from AZs B and C crosses to AZ A for NAT egress —
if the NAT gateway or AZ A becomes unavailable, those subnets lose internet egress.

### Grandfathered CloudFormation exports — not reproduced here

The CFN network stack exports two legacy names that pre-date the
`routebox-<env>-<resource>` convention:

- `${env}-vpc` — the VPC ID
- `${env}-subnet-private-a` — private subnet A ID

Terraform does not produce CloudFormation `!ImportValue`-consumable exports, so these
names **cannot be reproduced**. The consumer stacks (`rds`, `ecs-cluster`, and others)
that still reference these via `!ImportValue` must be migrated off — or given a shim —
before this module can replace the CFN stack in any environment. This is a coordinated
multi-stack effort and is **out of scope for the network migration PR**.

### Tags

Resources carry:

- `Environment` = `var.environment` — applied via `default_tags` in each env's provider block
- `ManagedBy` = `"terraform"` — **changed from `cloudformation`** in the original stack.
  Update any cost-allocation queries or AWS Config rules that filter on `ManagedBy: cloudformation`.
- `CostCenter` = `var.cost_center` — applied via `default_tags`
- `Name` = per-resource, following the CFN convention (`routebox-<env>-<resource>`)
- `Tier` = `"public"` or `"private"` on subnets (matching the CFN `Tier` tag)

### Jenkins SG — SSH ingress TODO

The original CFN template has a comment that port 22 (SSH) ingress from a bastion CIDR
is a TODO and has never been implemented. This is preserved as a `# TODO` comment in
`aws_security_group.jenkins`. Add the ingress rule when the bastion CIDR is defined.

### ECS SG — broad port range

The ECS service SG allows TCP 0–65535 inbound from the ALB SG. This matches the CFN
template verbatim. The CFN template itself notes this is broader than ideal and that
per-service tightening would be better. Preserved as-is for fidelity; tighten in a
follow-up if desired.
