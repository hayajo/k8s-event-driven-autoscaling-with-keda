# Depoying myapp

## Deploying myapp with Helm Chart

```shell
helm install myapp . \
  --set queueURL=<sqs URL> \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<myapp IAM Role ARN> \
  --namespace=<project Namespace. e.g. "myproject"> \
  --create-namespace
```

### Change TriggerAuthentication spec.podIdentity.IdentityOwner to `workload`

```shell
helm upgrade myapp . \
  --set queueURL=<sqs URL> \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<myapp IAM Role ARN> \
  --set scaledObject.triggerAuthentication.identityOwner=workload \
  --namespace=<project Namespace>
```

### Use TriggerAuthentication spec.podIdentity.roleArn

```shell
helm upgrade myapp . \
  --set queueURL=<sqs URL> \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<myapp IAM Role ARN> \
  --set scaledObject.triggerAuthentication.roleArn="<sqs-scaler IAM Role ARN>" \
  --namespace=<project Namespace>
```

## Values

| Key | Type | Default |
|-----|------|---------|
| awsRegion | string | `"ap-northeast-1"` |
| queueURL | string | `""` |
| scaledObject.create | bool | `true` |
| scaledObject.maxReplicaCount | int | `3` |
| scaledObject.minReplicaCount | int | `0` |
| scaledObject.queueLength | int | `3` |
| scaledObject.triggerAuthentication.identityOwner | string | `"keda"` |
| scaledObject.triggerAuthentication.roleArn | string | `""` |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` |
