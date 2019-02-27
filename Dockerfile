FROM golang:1.11-alpine

ARG GLIBC_VERSION=2.25-r0
ARG PROTOC_VERSION=3.5.1

## Used for building python protos and grpc
RUN apk add py-pip musl libc6-compat linux-headers build-base python-dev
RUN python -m pip install grpcio-tools
## delete it after building because it conflicts with glibc pacage below
RUN apk del libc6-compat


# Install tools of general use
RUN apk add --no-cache su-exec curl bash git openssh mercurial make ca-certificates expect docker

# Install glibc from sgerrand/alpine-pkg-glibc
RUN curl -sSL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub > /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk > glibc-${GLIBC_VERSION}.apk && \
	apk add --no-cache glibc-${GLIBC_VERSION}.apk && \
	rm -f glibc-${GLIBC_VERSION}.apk

# Disable cgo so we get fully static binaries.
ENV CGO_ENABLED=0

# Recompile the standard library with cgo disabled.  This prevents the standard
# library from being marked stale, causing full rebuilds every time.
RUN go install -v std

# Install Ginkgo and Gomega to run tests
RUN go get github.com/onsi/ginkgo/ginkgo && \
	go get github.com/onsi/gomega

# Install coverage tools to produce coverage reports
RUN go get github.com/wadey/gocovmerge && \
	go get github.com/axw/gocov/gocov && \
	go get github.com/AlekSi/gocov-xml

# Install fmt and lint
RUN go get golang.org/x/lint/golint && \
	go get github.com/golang/dep/cmd/dep

# Install gobindata to bake in swagger
RUN go get github.com/jteeuwen/go-bindata/go-bindata

# Install boilr to generate services
RUN go get github.com/tmrts/boilr && \
    cd $GOPATH/src/github.com/tmrts/boilr && \
    git remote add fork https://github.com/smousa/boilr.git && \
    git fetch fork format-camel && \
    git checkout format-camel && \
    go install

# Install protoc and go plug-in
RUN mkdir /tmp/protoc && \
    curl -sSL https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip > /tmp/protoc/protoc.zip && \
    unzip -qo /tmp/protoc/protoc.zip -d /tmp/protoc && \
    cp /tmp/protoc/bin/protoc /usr/bin && \
    mkdir -p /usr/include && \
    cp -R /tmp/protoc/include/google /usr/include/. && \
    chmod a+x /usr/bin/protoc && \
    chmod -R 777 /usr/include/google && \
    rm -rf /tmp/protoc && \
    go get -u github.com/golang/protobuf/protoc-gen-go

# Install grpc-java plugin
RUN apk add grpc-java --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/

# Include Node.js and yarn
RUN apk add --no-cache nodejs nodejs-npm && npm install -g yarn

# Install mockery
RUN go get github.com/vektra/mockery/.../

# Ensure that everything under the GOPATH is writable by everyone
RUN chmod -R 777 $GOPATH

# Disable ssh host key checking
RUN echo 'Host *' >> /etc/ssh/ssh_config
RUN echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config

COPY create-zenkit.sh /usr/local/bin/create-zenkit.sh
COPY create-zenkit-local.sh /usr/local/bin/create-zenkit-local.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ONBUILD ARG GITHUB_USERNAME
ONBUILD ARG GITHUB_PASSWORD
ONBUILD RUN if [ -n "${GITHUB_USERNAME}" ]; then \
    printf 'https://%s:%s@github.com' "${GITHUB_USERNAME}" "${GITHUB_PASSWORD}" > /etc/.git_creds; \
    git config --global credential.helper 'store --file /etc/.git_creds'; \
    git config --global url.'https://github.com'.insteadOf 'ssh://git@github.com'; \
    fi

ONBUILD ARG SSH_PRIVATE_KEY
ONBUILD RUN if [ -n "${SSH_PRIVATE_KEY}" ]; then \
    mkdir /root/.ssh; \
    echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa; \
    chmod 600 /root/.ssh/id_rsa; \
    touch /root/.ssh/known_hosts; \
    ssh-keyscan github.com >> /root/.ssh/known_hosts; \
    fi

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
