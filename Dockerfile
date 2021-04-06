FROM quay.io/luet/base:develop
ADD conf/luet.yaml.docker /etc/luet/luet.yaml
ADD conf/repos.conf.d/ /etc/luet/repos.conf.d

ENV USER=root

SHELL ["/usr/bin/luet", "install", "-y"]
RUN repository/luet
RUN repository/mocaccino-extra-stable
RUN repository/mocaccino-os-commons-stable
RUN repository/mocaccino-portage
RUN sys-devel/gcc
RUN sys-apps/systemd
RUN sys-apps/dbus
RUN app-shell/bash

SHELL ["/bin/bash", "-c"]
RUN rm -rf /var/cache/luet/packages/ /var/cache/luet/repos/ /var/tmp/luet/

ENV TMPDIR=/tmp
ENTRYPOINT ["/bin/bash"]
