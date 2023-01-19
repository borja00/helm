*kubectl create -f namespace-dev.yaml
helm upgrade -i frontend frontend -f frontend/values.yaml*

* Install APP
```
make init
cd helm-charts
helm dependency build app

helm upgrade -i app app -f app/values.yaml --namespace dev --create-namespace
```

* Access App
```
echo http://$(minikube ip)
```


* Backup
```
kubectl config set-context --current --namespace=dev
make backup
```

* Restore
```
kubectl config set-context --current --namespace=dev
make restore
```
* Cleanup
```
make cleanup
```


* Improvements
  * Change how password is generated
  * Use gzip or other compression mechanism for backups
  * Fix prompt errors when running make restore/backup commands