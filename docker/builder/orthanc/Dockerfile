FROM osimis/orthanc-base

ADD ./build.sh /root/build.sh
RUN bash /root/build.sh "Orthanc-1.2.0" # CHANGE_VERSION

# VOLUME [ "/var/lib/orthanc/db" ]
EXPOSE 4242
EXPOSE 8042

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
