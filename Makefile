VERSION := 1.7.7

default: zenoss/zenkit-build

.PHONY: zenoss/zenkit-build
zenoss/zenkit-build:
	@docker build -t $@:$(VERSION) .
