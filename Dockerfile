# Docker container image for building apps hosted on LLVM.

FROM       ubuntu:saucy
MAINTAINER Chris Corbyn <chris@w3style.co.uk>

RUN apt-get update -qq -y
RUN apt-get install -qq -y wget

RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -

ADD llvm.org.list /etc/apt/sources.list.d/llvm.org.list

RUN apt-get update -qq -y
RUN apt-get install -qq -y \
    make \
    clang-3.4 \
    clang-3.4-doc \
    libclang-common-3.4-dev \
    libclang-3.4-dev \
    libclang1-3.4 \
    libclang1-3.4-dbg \
    libllvm-3.4-ocaml-dev \
    libllvm3.4 \
    libllvm3.4-dbg \
    lldb-3.4 \
    llvm-3.4 \
    llvm-3.4-dev \
    llvm-3.4-doc \
    llvm-3.4-examples \
    llvm-3.4-runtime \
    clang-modernize-3.4 \
    clang-format-3.4 \
    python-clang-3.4 \
    lldb-3.4-dev

RUN for f in $(find /usr/bin -name '*-3.4'); \
    do \
      ln -s $f `echo $f | sed s/-3.4//`; \
    done


# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM dockerfile/supervisor
MAINTAINER Kevin Delfour <kevin@delfour.eu>
# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev
# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh
# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/
# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace
# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8181
# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
