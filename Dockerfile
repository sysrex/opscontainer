ARG DEBIAN_VERSION=bullseye-slim

FROM debian:${DEBIAN_VERSION}
ARG CREATED
ARG COMMIT
ARG VERSION=local
LABEL \
    org.opencontainers.image.authors="alex@sysrex.com" \
    org.opencontainers.image.created=$CREATED \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.url="https://github.com/sysrex/opscontainer" \
    org.opencontainers.image.documentation="https://github.com/sysrex/opscontainer" \
    org.opencontainers.image.source="https://github.com/sysrex/opscontainer" \
    org.opencontainers.image.title="Base Dev container Debian" \
    org.opencontainers.image.description="Base Debian development container for Visual Studio Code Remote Containers development"
ENV BASE_VERSION="${VERSION}-${CREATED}-${COMMIT}"

# CA certificates
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -r /var/cache/* /var/lib/apt/lists/*

# Timezone
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends tzdata && \
    rm -r /var/cache/* /var/lib/apt/lists/*
ENV TZ=Europe/London

# Setup Git and SSH
# Workaround for older Debian in order to be able to sign commits
RUN echo "deb https://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends -t bookworm git git-man && \
    rm -r /var/cache/* /var/lib/apt/lists/*
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends man openssh-client less && \
    rm -r /var/cache/* /var/lib/apt/lists/*
COPY .ssh.sh /root/
RUN chmod +x /root/.ssh.sh
# Retro-compatibility symlink
RUN  ln -s /root/.ssh.sh /root/.windows.sh

# Setup shell
ENTRYPOINT [ "/bin/zsh" ]
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends zsh nano locales wget && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -r /var/cache/* /var/lib/apt/lists/*
ENV EDITOR=nano \
    LANG=en_US.UTF-8 \
    # MacOS compatibility
    TERM=xterm
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8
RUN usermod --shell /bin/zsh root

COPY shell/.zshrc shell/.welcome.sh /root/
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

ARG POWERLEVEL10K_VERSION=v1.16.1
COPY shell/.p10k.zsh /root/
RUN git clone --branch ${POWERLEVEL10K_VERSION} --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k/.git

# Setup Kubectl and Helm