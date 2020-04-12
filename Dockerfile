FROM debian:buster-slim

ARG UID="1000"
ARG GID="100"
ARG WORKDIR="/home/docker"

ARG PROFILEDIR=".profile"

ENV THUNDERBIRD_PROFILE_PATH=$WORKDIR/$PROFILEDIR

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    x2goserver x2goserver-xsession \
    openbox ttf-dejavu rxvt-unicode-256color \
    thunderbird \
 # Cleanup
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a user
RUN getent group $GID || groupadd --gid $GID --system nonroot \
 && useradd --uid $UID --gid $GID \
    --home-dir $WORKDIR --shell /bin/bash \
    --no-log-init --system nonroot \
 && echo 'nonroot:nonroot' | chpasswd \
 && mkdir -p $WORKDIR/.ssh && chmod 700 $WORKDIR/.ssh \
 && mkdir -p $WORKDIR/$PROFILEDIR

# Create SSH key pair
RUN ssh-keygen -q -t rsa -N "" -f $WORKDIR/.ssh/id_rsa \
 && cat $WORKDIR/.ssh/id_rsa.pub >> $WORKDIR/.ssh/authorized_keys

# Set SSHD config
COPY ./sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd && ssh-keygen -A

# Add required files
COPY ./thunderbird /usr/local/bin/thunderbird
COPY ./notify /notify
RUN chmod +x /usr/local/bin/thunderbird
RUN chmod +x /notify

RUN chown -R $UID:$GID /usr/local/bin/thunderbird /notify

EXPOSE 22
VOLUME $WORKDIR/$PROFILEDIR

CMD /usr/sbin/sshd -D
