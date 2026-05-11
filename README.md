# routebox-infra-tf

Terraform for Routebox AWS infrastructure. **Migration in progress** — the CloudFormation
stacks in `routebox-infra` are being ported here one stack at a time. The live infrastructure
is still managed by CloudFormation; this configuration has not been applied against any
environment.

## Migration status

| Stack | CFN source | TF module | Environments wired |
|---|---|---|---|
| `network` | `routebox-infra/cfn/network/` | `network/` | dev, staging, prod |
| `iam` | `routebox-infra/cfn/iam/` | _not started_ | — |
| `ecs-cluster` | `routebox-infra/cfn/ecs-cluster/` | _not started_ | — |
| `rds` | `routebox-infra/cfn/rds/` | _not started_ | — |
| `ecr` | `routebox-infra/cfn/ecr/` | _not started_ | — |
| `secrets-bootstrap` | `routebox-infra/cfn/secrets-bootstrap/` | _not started_ | — |

> **Applying the `network` module against an account where `routebox-network-<env>` already
> exists via CloudFormation will create duplicate/parallel resources.** A cutover plan
> (including `terraform import` blocks) is a separate workstream. See `network/README.md`
> for the full list of caveats.

## Repository layout

```
.
├── network/            ← reusable module (the only one so far)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── environments/
    ├── dev/            ← Terraform root for dev
    ├── staging/        ← Terraform root for staging
    └── prod/           ← Terraform root for prod
```

Each `environments/<env>/` is an independent Terraform root module. Operations run from
within that directory.

## Working with an environment

```bash
cd environments/dev

# First time: fill in backend.tf with real bucket/key/region/dynamodb_table values, then:
terraform init -reconfigure

# Plan (uses env-specific tfvars)
terraform plan -var-file=dev.tfvars

# Apply
terraform apply -var-file=dev.tfvars
```

Repeat for `staging` and `prod` using the respective tfvars file.

## Before applying anywhere

1. Fill in `environments/<env>/backend.tf` — the S3 bucket, DynamoDB lock table, and
   region are left as TODO placeholders. Do not invent names; coordinate with the platform
   team.
2. Verify AWS credentials and IAM permissions.
3. Review the cutover plan (TBD) — see `network/README.md` for the grandfathered
   CloudFormation export names that consumer stacks still depend on.

## Conventions

- All resources carry `Environment`, `ManagedBy = "terraform"`, and `CostCenter` tags via
  `default_tags` in the provider block. Individual resources also set a `Name` tag matching
  the CFN naming convention (`routebox-<env>-<resource>`).
- Stack names in CloudFormation were `routebox-<stack>-<env>`. The equivalent Terraform
  state key is `<stack>/<env>/terraform.tfstate` (see `backend.tf` in each env dir).
- Provider version is pinned to `~> 5.0` and Terraform to `>= 1.6`. The lock file
  (`.terraform.lock.hcl`) is committed.
