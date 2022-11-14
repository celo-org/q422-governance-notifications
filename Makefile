commitsh := $(shell git rev-parse HEAD)

processor:
	docker build ./processor -t event-processor-q422

notifier:
	docker build ./notifier -t event-notifier-q422

deploy: 
	helm template --set commitsh='$(commitsh)' rc1staging ops/helm | kubectl apply -n event-notifications -f -

validate_templates: 
	helm template --set commitsh='$(commitsh)' rc1staging ops/helm | kubectl apply -n event-notifications --validate=true --dry-run=client -f -

templates: 
	helm template --set commitsh='$(commitsh)' rc1staging ops/helm 

telegram:
	docker build ./telegram -t telegram-q422:$(commitsh)

push_telegram: telegram
	docker image tag telegram-q422:$(commitsh) gcr.io/celo-testnet-production/telegram-q422:$(commitsh)
	docker image push gcr.io/celo-testnet-production/telegram-q422:$(commitsh)

.PHONY: processor notifier deploy templates telegram