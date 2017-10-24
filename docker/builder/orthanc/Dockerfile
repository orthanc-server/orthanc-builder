FROM osimis/orthanc-builder-base:current
ARG ORTHANC_VERSION
COPY build.sh /root/build.sh
RUN /root/build.sh $ORTHANC_VERSION
ENTRYPOINT ["Orthanc"]
CMD ["/etc/orthanc/"]
