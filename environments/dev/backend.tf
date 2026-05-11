terraform {
  backend "s3" {
    # TODO: Fill in real values before running terraform init.
    # These placeholders must be replaced by the operator before first use.
    # Run:
    #   terraform init -reconfigure \
    #     -backend-config="bucket=<your-tfstate-bucket>" \
    #     -backend-config="key=network/dev/terraform.tfstate" \
    #     -backend-config="region=<your-aws-region>"
    bucket       = "routebox-tfstate-dev-us-east-1"
    key          = "network/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3 native locking — no DynamoDB table required
  }
}
