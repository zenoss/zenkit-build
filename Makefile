VERSION := py-proto

default: zenoss/zenkit-build

.PHONY: zenoss/zenkit-build
zenoss/zenkit-build:
	@docker build -t $@:$(VERSION) .
