docker build -t jre21-al2-slim .
docker run -v $(pwd)/layer:/tmp -it jre21-al2-slim sh -c "cp /opt/jre-21-slim.zip /tmp"
