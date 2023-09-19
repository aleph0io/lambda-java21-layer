FROM amazonlinux:2 as packager

RUN yum -y update \
    && yum install -y tar zip gzip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
    less libcurl-devel openssl openssl-devel readline-devel xz-devel \
    zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static \
    && rm -rf /var/cache/yum

ENV JDK_FOLDERNAME jdk-21
ENV JDK_FILENAME openjdk-21_linux-x64_bin.tar.gz
RUN curl -4 -L https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz | tar -xvz
RUN mv $JDK_FOLDERNAME /usr/lib/jdk21
RUN yum install -y binutils
RUN rm -rf $JDK_FOLDERNAME
ENV PATH="/usr/lib/jdk21/bin:$PATH"
RUN jlink --add-modules "$(java --list-modules | cut -f1 -d'@' | tr '\n' ',')" --compress 0 --no-man-pages --no-header-files --strip-debug --output /opt/jre21-slim
RUN find /opt/jre21-slim/lib -name *.so -exec strip -p --strip-unneeded {} \;
RUN java -Xshare:dump -version
RUN rm /opt/jre21-slim/lib/classlist
RUN cp /usr/lib/jdk21/lib/server/classes.jsa /opt/jre21-slim/lib/server/classes.jsa
RUN cd /opt/ && zip -r jre-21-slim.zip jre21-slim
