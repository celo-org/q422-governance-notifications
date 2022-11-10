processor:
	docker build ./processor -t event-processor-q422

notifier:
	docker build ./notifier -t event-notifier-q422

deploy: 
	helm template rc1staging ops/helm | kubectl apply -n event-notifications -f -

templates: 
	helm template rc1staging ops/helm 

telegram:
	docker build ./telegram -t telegram-q422:latest

push_telegram: telegram
	docker image tag telegram-q422:latest gcr.io/celo-testnet-production/telegram-q422:latest
	docker image push gcr.io/celo-testnet-production/telegram-q422:latest

.PHONY: processor notifier deploy templates telegram