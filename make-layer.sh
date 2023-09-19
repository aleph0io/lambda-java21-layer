#!/bin/sh

# -4 IPv4 only
# -L follow redirect if the server responds with a redirect
mkdir layer
curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-runtime-interface-client/2.4.1/aws-lambda-java-runtime-interface-client-2.4.1.jar -o layer/aws-lambda-java-runtime-interface-client-2.4.1.jar
curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-core/1.2.3/aws-lambda-java-core-1.2.3.jar -o layer/aws-lambda-java-core-1.2.3.jar
curl -4 -L https://repo.maven.apache.org/maven2/com/amazonaws/aws-lambda-java-serialization/1.1.2/aws-lambda-java-serialization-1.1.2.jar -o layer/aws-lambda-java-serialization-1.1.2.jar

chmod 755 bootstrap

cp bootstrap layer

pushd layer

rm -rf jre21-slim
unzip jre-21-slim.zip

rm -f ../java21layer.zip
zip -r ../java21layer.zip bootstrap jre21-slim aws-lambda-java-runtime-interface-client-2.4.1.jar aws-lambda-java-core-1.2.3.jar aws-lambda-java-serialization-1.1.2.jar

popd
