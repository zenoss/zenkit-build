VERSION := 1.8.1

default: zenoss/zenkit-build

.PHONY: zenoss/zenkit-build
zenoss/zenkit-build:
	@docker build -t $@:$(VERSION) .
