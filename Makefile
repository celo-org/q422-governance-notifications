deploy: 
	helm template rc1staging ops/helm | kubectl apply -n event-notifications -f -

