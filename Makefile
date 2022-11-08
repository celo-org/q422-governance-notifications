processor:
	docker build ./processor -t event-processor-q422


deploy: 
	helm template rc1staging ops/helm | kubectl apply -n event-notifications -f -

.PHONY: processor