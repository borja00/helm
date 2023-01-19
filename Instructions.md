# Instructions 
## Install APP
```
make init
cd helm-charts
helm dependency build app

helm upgrade -i app app -f app/values.yaml --namespace dev --create-namespace
```

If you see this error it means minikube is still installing ingress controller, wait a few seconds and try again.
```
Error: UPGRADE FAILED: failed to create resource: Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": Post "https://ingress-nginx-controller-admission.ingress-nginx.svc:443/networking/v1/ingresses?timeout=10s": dial tcp 10.111.138.0:443: connect: connection refused
```

## Access App
```
echo http://$(minikube ip)
```


## Backup
```
kubectl config set-context --current --namespace=dev
make backup
```

## Restore
```
kubectl config set-context --current --namespace=dev
make restore
```
## Cleanup
```
make cleanup
```


# Improvements
  * Do not use admin postgres user/password for backend service
  * Use gzip or other compression mechanism for backups
  * Fix prompt errors when running make restore/backup commands
  * Use HTTP healthcheck from services
  * Add pipeline and use OCI registry for project