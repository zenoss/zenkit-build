FROM golang:1.9rc1-alpine

ARG GLIBC_VERSION=2.25-r0

# Install tools of general use
RUN apk add --no-cache su-exec curl bash git openssh mercurial make ca-certificates expect docker

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
RUN go get github.com/tmrts/boilr

# Install dredd to run integration tests
RUN cd / && \
    apk add --no-cache --update nodejs nodejs-npm gcc g++ python && \
    npm config set loglevel error && \
    npm install npm@latest -g && \
    npm install dredd && \
    apk del gcc g++ python && \
    go get github.com/snikch/goodman/cmd/goodman
ENV PATH ${PATH}:/node_modules/.bin

# Ensure that everything under the GOPATH is writable by everyone
RUN chmod -R 777 $GOPATH

# Disable ssh host key checking
RUN echo 'Host *' >> /etc/ssh/ssh_config
RUN echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config

COPY create-zenkit.sh /usr/local/bin/create-zenkit.sh
COPY create-zenkit-local.sh /usr/local/bin/create-zenkit-local.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
