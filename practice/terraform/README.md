# Create test environments

Terraform module to create test environments for [KEDA](https://keda.sh/) and Amazon SQS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.keda_operator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.myapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sqs_scaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.keda_operator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.myapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sqs_scaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.keda_operator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.myapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sqs_scaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.myapp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the project. e.g. "myproject" | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster security group will be provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keda_operator_iam_role_arn"></a> [keda\_operator\_iam\_role\_arn](#output\_keda\_operator\_iam\_role\_arn) | The ARN of the IAM role created for the keda-operator ServiceAccount |
| <a name="output_myapp_iam_role_arn"></a> [myapp\_iam\_role\_arn](#output\_myapp\_iam\_role\_arn) | The ARN of the IAM role created for the myapp ServiceAccount |
| <a name="output_sqs_scaler_iam_role_arn"></a> [sqs\_scaler\_iam\_role\_arn](#output\_sqs\_scaler\_iam\_role\_arn) | The ARN of the IAM role created for the AWS SQS Queue Scaler |
| <a name="output_sqs_url"></a> [sqs\_url](#output\_sqs\_url) | The URL for the created Amazon SQS queue |
<!-- END_TF_DOCS -->
