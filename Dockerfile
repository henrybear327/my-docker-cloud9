FROM        ubuntu:trusty
MAINTAINER  Robin Sommer <robin@icir.org>

# Setup environment.
ENV PATH /opt/llvm/bin:$PATH

# Default command on startup.
CMD bash

# Setup packages.
RUN apt-get update && apt-get -y install cmake git build-essential vim python

# Copy install-clang over.
ADD . /opt/install-clang

# Compile and install LLVM/clang. We delete the source directory to
# avoid committing it to the image.
RUN /opt/install-clang/install-clang -j 4 -C /opt/llvm

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
