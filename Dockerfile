FROM golang:1.8.3-alpine

ARG GLIBC_VERSION=2.25-r0

# Install tools of general use
RUN apk add --no-cache curl bash git openssh mercurial make ca-certificates

# Install glibc from sgerrand/alpine-pkg-glibc
RUN curl -sSL https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub > /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk > glibc-${GLIBC_VERSION}.apk && \
	apk add --no-cache glibc-${GLIBC_VERSION}.apk && \
	rm -f glibc-${GLIBC_VERSION}.apk

# Disable cgo so we get fully static binaries.
ENV CGO_ENABLED=0

# Recompile the standard library with cgo disabled.  This prevents the standard
# library from being marked stale, causing full rebuilds every time.
RUN go install -v std

# Install Glide to manage dependencies
RUN go get github.com/Masterminds/glide

# Install Ginkgo to run tests
RUN go get github.com/onsi/ginkgo/ginkgo

# Install gocovmerge to merge coverage reports
RUN go get github.com/wadey/gocovmerge

# Ensure that everything under the GOPATH is writable by everyone
RUN chmod -R 777 $GOPATH
