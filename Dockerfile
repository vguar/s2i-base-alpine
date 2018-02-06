FROM alpine:3.7

LABEL \
  # Location of the STI scripts inside the image
  io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
  # DEPRECATED: This label will be kept here for backward compatibility
  io.s2i.scripts-url=image:///usr/libexec/s2i

ENV \
  # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
  STI_SCRIPTS_URL=image:///usr/libexec/s2i \
  # Path to be used in other layers to place s2i scripts into
  STI_SCRIPTS_PATH=/usr/libexec/s2i \
  # HOME is not set by default, but is needed by some applications
  HOME=/opt/app-root/src \
  PATH=/opt/app-root/src/bin:/opt/app-root/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:$PATH 

RUN mkdir -p ${HOME} && \
    mkdir -p /usr/libexec/s2i && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 /opt/app-root && \
    apk -U upgrade && \
    apk add --no-cache --update bash curl wget \
    tar unzip findutils git gettext gdb lsof patch \
    libcurl libxml2 libxslt which ca-certificates && \
    update-ca-certificates --fresh

# Copy extra files to the image.
COPY ./root/ /

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
WORKDIR ${HOME}

ENTRYPOINT ["container-entrypoint"]
CMD ["base-usage"]
