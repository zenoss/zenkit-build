# Contributor: wener <wenermail@gmail.com>
# Maintainer: wener <wenermail@gmail.com>
pkgname=grpc-java
pkgver=1.13.1
pkgrel=0
pkgdesc="The Java gRPC implementation. HTTP/2 based RPC"
url="https://github.com/grpc/grpc-java"
arch="all !aarch64 !armhf !s390x" # fails to build on aarch64 and armhf for some strange reason
license="Apache2"
depends="openjdk8-jre"
makedepends="openjdk8 protobuf-dev"
source="$pkgname-$pkgver.tar.gz::https://github.com/grpc/grpc-java/archive/v$pkgver.tar.gz"
builddir="$srcdir/$pkgname-$pkgver"
options="!check"

build() {
	export GRADLE_USER_HOME="$srcdir"/.gradle
	cd "$builddir"/compiler
	../gradlew --no-daemon --parallel --info java_pluginExecutable
}

package() {
	install -D -m 755 "$builddir"/compiler/build/exe/java_plugin/protoc-gen-grpc-java "$pkgdir"/usr/bin/protoc-gen-grpc-java
}

sha512sums="950e5302f7ee7a5c14b51e77c81a2f532df87605c8439f96da616f4627f30d3294a109a4c6d9aca548f680e1d7d68acda9db0298f7773e093ed2cad4bbb005af  grpc-java-1.13.1.tar.gz"
