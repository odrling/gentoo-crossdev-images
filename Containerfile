FROM docker.io/gentoo/portage as portage

FROM docker.io/gentoo/stage3:nomultilib

ARG TARGET

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo
COPY gentoobinhost.conf /etc/portage/binrepos.conf/gentoobinhost.conf
COPY package.use /etc/portage/package.use/gentoo-crossdev-image

RUN echo 'FEATURES="${FEATURES} binpkg-request-signature"' >> /etc/portage/make.conf && \
    echo 'CPU_FLAGS_X86="avx avx2 f16c fma3 mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"' >> /etc/portage/make.conf && \
    echo 'USE="libass x264 opus"' >> /etc/portage/make.conf && \
    emerge -uvNDg @world sys-devel/crossdev dev-vcs/git dev-build/meson dev-lang/go net-libs/nodejs media-video/ffmpeg media-libs/libass

RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} && \
    echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name && \
    echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf && \
    chown -R portage:portage /var/db/repos/crossdev

COPY crossdev.conf /etc/portage/repos.conf/crossdev.conf

RUN FEATURES="${FEATURES} -ipc-sandbox -network-sandbox -pid-sandbox binpkg-request-signature" crossdev -t $TARGET

RUN rm -r /var/cache /var/db/repos
