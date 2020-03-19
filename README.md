# zenkit-build

A build image for zenkit microservices. Also contains glide for dependency
management, and ginkgo, gocovmerge and dredd, for running tests.

## A note on zenkit-build:1.8.0:
zenkit-build 1.8.0 uses go1.14, which uses go modules by default.  Here are the steps for migrating a microservice to go1.14:
1. Switch your local environment to go1.14 (steps below are for gvm)
```
OLDGOPATH=$GOPATH
gvm install go1.14 --default
gvm use go1.14
GOPATH=$OLDGOPATH
```
2. If the repo has already been converted to go modules, follow these steps.  Otherwise, skip to 3.
```
# Remove old go mod and vendor stuff
rm -rf vendor go.mod go.sum
# Re-initialize go mod
go mod init <module name> # i.e. go mod init github.com/zenoss/yamr
go mod vendor
```
3. Set the GOPRIVATE environment variable to treat everything from github as a private repo.  This prevents errors like "fatal: could not read Username for 'https://github.com': terminal prompts disabled":
```
go env -w GOPRIVATE=github.com
```
4. Check the Makefile and Dockerfile and add `-mod=vendor` to all `go` and `ginkgo` commands.  This tells these commands to use the vendored dependencies rather than attempting to pull them from github (which will fail if inside a container).
    1. Example1: 
    `RUN go build -o /bin/yamr` 
    should be 
    `RUN go build -mod=vendor -o /bin/yamr`
    2. Example2: 
    `$(GINKGO) -r -cover -covermode=count --skipPackage vendor --tags integration` 
    should be:
    `$(GINKGO) -mod vendor -r -cover -covermode=count --skipPackage vendor --tags integration`

## Building zenkit-build
This image is built automatically on [dockerhub](https://cloud.docker.com/u/zenoss/repository/docker/zenoss/zenkit-build/)
any time changes are released to master.
Check the [Builds](https://cloud.docker.com/u/zenoss/repository/docker/zenoss/zenkit-build/builds) page on dockerhub for build status.

## Releasing zenkit-build
zenkit-build uses standard [semantic versioning](https://semver.org/), but without the formality of git-flow-release.
Once you have a set of changes merged to the master branch and ready for release, generate a git tag for it and push
the tag to github:

```
git checkout master
git pull

export TAG=<yourVersionNumberHere>
git tag -a ${TAG} -m "release ${TAG}"
git push origin ${TAG}
```

Shortly after pushing the new tag, dockerhub will start a build based on the tag you added.

## Using transcoding mappings for HTTP

You can decorate your protobufs to enable HTTP transcoding to gRPC as described
in this Google [tutorial](https://cloud.google.com/endpoints/docs/grpc/transcoding#adding_transcoding_mappings).

To build protobufs with these transcodings, you can use `zenkit-build:1.7.7` or higher, but
you must also add the following to your `protoc` command(s) - `--proto_path=${GOPATH}/googleapis`.
