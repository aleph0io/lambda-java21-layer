# AWS Lambda Java 17 Custom Runtime (DEPRECATED)

This project is no longer required, as [AWS Lambda now supports Java 17](https://aws.amazon.com/blogs/compute/java-17-runtime-now-available-on-aws-lambda/). I've left it here because others might find it's approach useful for other experimentation. 


An AWS Lambda layer to enable Java 17 support

## Usage

### with CDK

- Download [java17layer.zip](https://github.com/msailes/lambda-java17-layer/releases/download/v0.0.1-alpha/java17layer.zip)
- Create a Lambda layer using Code.fromAsset `java17layer.zip`
- Note you might need to adjust the path for your own project structure

```java 
LayerVersion java17layer = new LayerVersion(this, "Java17Layer", LayerVersionProps.builder()
        .layerVersionName("Java17Layer")
        .description("Java 17")
        .compatibleRuntimes(Arrays.asList(Runtime.PROVIDED_AL2))
        .code(Code.fromAsset("java17layer.zip"))
        .build());
```

- Create a function using the PROVIDED_AL2 runtime.
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
        .layers(singletonList(java17layer))
        .build());
```

## Layer Details

### Java 17 

A custom JRE is created to reduce final file size. Lambda has a 250MB unzipped file size limit.

[Dockerfile](Dockerfile) describes how the JRE is built.

### JVM Settings

The following JVM settings are added by default.

```
--add-opens java.base/java.util=ALL-UNNAMED 
-XX:+TieredCompilation -XX:TieredStopAtLevel=1 
-Xshare:on
```

Further suggestions welcomed

### Java Class Path

```
aws-lambda-java-runtime-interface-client-1.1.0.jar
aws-lambda-java-core-1.2.1.jar
aws-lambda-java-serialization-1.0.0.jar
$LAMBDA_TASK_ROOT
$LAMBDA_TASK_ROOT/*
$LAMBDA_TASK_ROOT/lib/*
```

## Build the layer zip yourself

### Requirements

- Docker

### Steps

- Run `build-jre.sh` to build the minimal Java 17 runtime
- Run `make-layer.sh` to package the runtime, dependencies and bootstrap as a zip

