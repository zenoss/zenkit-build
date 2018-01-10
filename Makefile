VERSION := 1.6.4

default: zenoss/zenkit-build

.PHONY: zenoss/zenkit-build
zenoss/zenkit-build:
	@docker build -t $@:$(VERSION) .
