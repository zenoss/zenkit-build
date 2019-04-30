# zenkit-build

A build image for zenkit microservices. Also contains glide for dependency
management, and ginkgo, gocovmerge and dredd, for running tests.

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
git tag -a${TAG} -m "release ${TAG}"
git push origin ${TAG}
```

Shortly after pushing the new tag, dockerhub will start a build based on the tag you added.

## Using transcoding mappings for HTTP

You can decorate your protobufs to enable HTTP transcoding to gRPC as described
in this Google [tutorial](https://cloud.google.com/endpoints/docs/grpc/transcoding#adding_transcoding_mappings).

To build protobufs with these transcodings, you can use `zenkit-build:1.7.7` or higher, but
you must also add the following to your `protoc` command(s) - `--proto_path=${GOPATH}/googleapis`.
