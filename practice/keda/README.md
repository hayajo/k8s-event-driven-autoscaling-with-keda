# Deploying KEDA

[Deploying KEDA \| KEDA](https://keda.sh/docs/2.14/deploy/)

## Deploying KEDA with Helm Chart

```shell
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

helm install keda kedacore/keda \
  --set podIdentity.aws.irsa.enabled=true \
  --set podIdentity.aws.irsa.roleArn=<keda-operator IAM Role ARN> \
  --version=2.14.0 \
  --namespace=keda \
  --create-namespace
```
