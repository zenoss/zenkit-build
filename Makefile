VERSION := 1.6.0

default: zenoss/zenkit-build

.PHONY: zenoss/zenkit-build
zenoss/zenkit-build:
	@docker build -t $@:$(VERSION) .
