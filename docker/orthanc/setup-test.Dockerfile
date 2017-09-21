FROM alpine
ENTRYPOINT ["bash"]
WORKDIR /tmp
RUN apk add --no-cache bash
RUN mkdir /etc/orthanc /run/secrets
COPY . .
