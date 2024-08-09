FROM docker.io/gentoo/portage as portage

FROM docker.io/gentoo/stage3

ARG TARGET
ARG LLVM_SLOT=17

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo
COPY gentoobinhost.conf /etc/portage/binrepos.conf/gentoobinhost.conf
COPY package.use /etc/portage/package.use/gentoo-crossdev-image

RUN echo 'FEATURES="${FEATURES} -ipc-sandbox -network-sandbox -pid-sandbox binpkg-request-signature"' >> /etc/portage/make.conf && \
    emerge -g sys-devel/crossdev sys-devel/clang:$LLVM_SLOT sys-devel/lld:$LLVM_SLOT dev-vcs/git

RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} && \
    echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name && \
    echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf && \
    chown -R portage:portage /var/db/repos/crossdev

COPY crossdev.conf /etc/portage/repos.conf/crossdev.conf

RUN FEATURES="${FEATURES} -ipc-sandbox -network-sandbox -pid-sandbox binpkg-request-signature" crossdev -L -t $TARGET

RUN rm -r /var/cache /var/db/repos
