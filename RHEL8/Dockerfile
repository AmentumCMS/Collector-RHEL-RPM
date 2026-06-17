FROM redhat/ubi8

RUN yum install -y yum-utils tree free &&\
    yum clean all &&\
    rm -rf /var/cache/yum

COPY ../scripts/*.sh /usr/local/bin

WORKDIR /RHEL
CMD ["/usr/local/bin/entrypoint.sh"]