FROM golang:1.8.3-alpine

ARG GLIBC_VERSION=2.25-r0

# Install tools of general use
RUN apk add --no-cache su-exec curl bash git openssh mercurial make ca-certificates expect

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
ENV GLIDE_HOME /home/user/.glide

# Install Ginkgo and Gomega to run tests
RUN go get github.com/onsi/ginkgo/ginkgo && \
	go get github.com/onsi/gomega

# Install coverage tools to produce coverage reports
RUN go get github.com/wadey/gocovmerge && \
	go get github.com/axw/gocov/gocov && \
	go get github.com/AlekSi/gocov-xml

# Install gobindata to bake in swagger
RUN go get github.com/jteeuwen/go-bindata/go-bindata

# Install boilr to generate services
RUN go get github.com/tmrts/boilr && \
	cd /go/src/github.com/tmrts/boilr && \
	git remote add iancmcc http://github.com/iancmcc/boilr && \
	git fetch iancmcc master:iancmcc-master && \
	git checkout iancmcc-master && \
	go install

# Ensure that everything under the GOPATH is writable by everyone
RUN chmod -R 777 $GOPATH

COPY create-zenkit.sh /usr/local/bin/create-zenkit.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
