FROM maven:3.6.3-openjdk-8 AS builder
 #  AS builder 起别名

RUN mkdir /build
# 创建临时文件

COPY ./ /build

#将 src目录复制到临时目录


RUN cd /build/bin/ && sh ./packages_linux.sh "jraspAgent" "noPackage"


FROM golang:1.18 AS builder2

RUN mkdir /build

ADD ./ /build

COPY --from=builder /build/target /build/target

RUN cd /build/bin/ && sh ./build_daemon.sh "jraspAttach" "noPackage" && sh ./build_daemon.sh "jraspDaemon"

# 使用带有OpenJDK 8的基础镜像
FROM ubuntu:latest

COPY --from=builder2 /build/target /app/target

RUN chmod +x /app/target/jrasp/bin/service.sh

WORKDIR /app/target/jrasp/bin

# 启动服务
CMD ["service.sh"]
