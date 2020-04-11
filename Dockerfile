FROM debian:buster-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    x2goserver x2goserver-xsession \
    openbox ttf-dejavu rxvt-unicode-256color \
    curl \
    # Install Thunderbird
    thunderbird \
    # Cleanup
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a user
RUN useradd -m docker && \
    mkdir -p /home/docker/.ssh && \
    chmod 700 /home/docker/.ssh && \
    chown docker:docker /home/docker/.ssh && \
    echo 'docker:docker' | chpasswd


# Create SSH key pair
RUN ssh-keygen -q -t rsa -N "" -f /home/docker/.ssh/id_rsa \
    && cat /home/docker/.ssh/id_rsa.pub >> /home/docker/.ssh/authorized_keys


# Set SSHD config
COPY ./sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd && ssh-keygen -A


# Thunderbird custom profile runner command
RUN mkdir /thunderbird-profile && chown docker:docker /thunderbird-profile
COPY ./thunderbird /usr/local/bin/thunderbird
RUN chmod +x /usr/local/bin/thunderbird
COPY ./notify /notify
RUN chmod +x /notify


VOLUME /home/docker/.ssh
VOLUME /thunderbird-profile
EXPOSE 22

CMD /usr/sbin/sshd -D
