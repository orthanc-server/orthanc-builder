FROM osimis/orthanc-base
ADD ./build.sh /root/build.sh
RUN /root/build.sh "Orthanc-1.2.0" # CHANGE_VERSION
ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
