# AWS Lambda Java 21 Custom Runtime

An AWS Lambda layer to enable Java 21 support.

## Usage

### In AWS Console

- Download [java21layer.zip](https://github.com/aleph0io/lambda-java21-layer/releases/download/v21.0.0-alpha.0/java21layer.zip)
- Upload to S3 (required to create a layer from a ZIP file greater than 50MB in size)
- In Lambda console, create a layer using this ZIP file using the `x86_64` architecture and the `Custom runtime on Amazon Linux 2` runtime
- In Lambda console, create a function with `Provide your own bootstrap on Amazon Linux 2` and architecture `x86_64`
- In Lambda function console, add the layer you created, and upload your [Java deployment package](https://docs.aws.amazon.com/lambda/latest/dg/java-package.html)
- Run
- (Hopefully) celebrate! 🥳

### with CDK

- Download [java21layer.zip](https://github.com/aleph0io/lambda-java21-layer/releases/download/v21.0.0-alpha.0/java21layer.zip)
- Create a Lambda layer using Code.fromAsset `java21layer.zip`
- Note you might need to adjust the path for your own project structure

```java 
LayerVersion java21layer = new LayerVersion(this, "Java21Layer", LayerVersionProps.builder()
        .layerVersionName("Java21Layer")
        .description("Java 21")
        .compatibleRuntimes(Arrays.asList(Runtime.PROVIDED_AL2))
        .code(Code.fromAsset("java21layer.zip"))
        .build());
```

- Create a function using the `PROVIDED_AL2` runtime.
- Add this layer to your function.

```java
Function exampleWithLayer = new Function(this, "ExampleWithLayer", FunctionProps.builder()
        .functionName("example-with-layer")
        .description("example-with-layer")
        .handler("example.HelloWorld::handleRequest")
        .runtime(Runtime.PROVIDED_AL2)
        .code(Code.fromAsset("../software/ExampleFunction/target/example.jar"))
        .memorySize(512)
        .logRetention(RetentionDays.ONE_WEEK)
        .layers(singletonList(java21layer))
        .build());
```

## Layer Details

### Java 21

A custom JRE is created to reduce final file size. Lambda has a 250MB unzipped file size limit.

[Dockerfile](Dockerfile) describes how the JRE is built.

## Known Issues

1. The layer fails [CDS](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/class-data-sharing.html) (Class Data Sharing) during initialization. This creates some log traffic, and may adversely affect performance.
2. It is only (lightly) tested
3. Only x86_64 is supported

### JVM Settings

The following JVM settings are added by default.

```
--add-opens java.base/java.util=ALL-UNNAMED 
-XX:+TieredCompilation -XX:TieredStopAtLevel=1 
-Xshare:auto
```

Further suggestions welcomed

### Java Class Path

```
aws-lambda-java-core-1.2.3.jar
aws-lambda-java-serialization-1.1.2.jar
aws-lambda-java-runtime-interface-client-2.4.1.jar
$LAMBDA_TASK_ROOT
$LAMBDA_TASK_ROOT/*
$LAMBDA_TASK_ROOT/lib/*
```

## Build the layer zip yourself

### Requirements

- Docker

### Steps

- Run `build-jre.sh` to build the minimal Java 21 runtime
- Run `make-layer.sh` to package the runtime, dependencies and bootstrap as a zip

## Acknowledgements

Much credit to [@msailes](https://github.com/msailes), who created the original repo from which this project is forked!

