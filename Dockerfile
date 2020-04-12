FROM debian:buster-slim

ARG UID="1000"
ARG GID="100"
ARG WORKDIR="/home/nonroot"

ARG PROFILEDIR=".thunderbird"

ENV NONROOT_UID=$UID
ENV NONROOT_GID=$GID
ENV NONROOT_HOME=$WORKDIR
ENV THUNDERBIRD_PROFILE_PATH=$WORKDIR/$PROFILEDIR

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    x2goserver x2goserver-xsession \
    openbox ttf-dejavu rxvt-unicode-256color \
    cron sqlite3 supervisor \
    thunderbird \
 # Cleanup
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a user
RUN getent group $GID || groupadd --gid $GID --system nonroot \
 && useradd --uid $UID --gid $GID \
    --home-dir $WORKDIR --shell /bin/bash \
    --no-log-init --system nonroot \
 && echo 'nonroot:nonroot' | chpasswd \
 && mkdir -p $WORKDIR/$PROFILEDIR

# Set SSHD config
COPY ./sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd

# Supoervisor & Cron
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./sqlite-optimize-profile.sh $WORKDIR/sqlite-optimize-profile.sh
RUN chmod +x $WORKDIR/sqlite-optimize-profile.sh
RUN echo "0 * * * * $WORKDIR/sqlite-optimize-profile.sh > /dev/null 2>&1" >> /etc/crontab

# Add required files
COPY ./ensure-ssh-key.sh /ensure-ssh-key.sh
COPY ./run-thunderbird $WORKDIR/run-thunderbird
COPY ./notify $WORKDIR/notify
RUN chmod +x /ensure-ssh-key.sh $WORKDIR/run-thunderbird $WORKDIR/notify

RUN chown -R $UID:$GID $WORKDIR

EXPOSE 22
VOLUME $WORKDIR/$PROFILEDIR
WORKDIR $WORKDIR

CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
