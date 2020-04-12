FROM ez123/haveged:1.9.8 as keygen
RUN apk add --no-cache openssh-keygen
RUN ssh-keygen -t rsa -b 4096 -f /id_rsa -N '' -C "nonroot@x2go-thunderbird"

FROM debian:buster-slim

ARG UID="1000"
ARG GID="100"
ARG WORKDIR="/home/nonroot"

ARG PROFILEDIR=".thunderbird"

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
 && mkdir -p $WORKDIR/.ssh && chmod 700 $WORKDIR/.ssh \
 && mkdir -p $WORKDIR/$PROFILEDIR

# Copy SSH key pair
COPY --from=keygen /id_rsa $WORKDIR/.ssh/id_rsa
COPY --from=keygen /id_rsa.pub $WORKDIR/.ssh/id_rsa.pub
RUN cat $WORKDIR/.ssh/id_rsa.pub >> $WORKDIR/.ssh/authorized_keys

# Set SSHD config
COPY ./sshd_config /etc/ssh/sshd_config
RUN mkdir -p /run/sshd && ssh-keygen -A

# Supoervisor & Cron
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./sqlite-optimize-profile.sh $WORKDIR/sqlite-optimize-profile.sh
RUN chmod +x $WORKDIR/sqlite-optimize-profile.sh
RUN echo "0 * * * * $WORKDIR/sqlite-optimize-profile.sh > /dev/null 2>&1" > /etc/crontab

# Add required files
COPY ./run-thunderbird $WORKDIR/run-thunderbird
COPY ./notify $WORKDIR/notify
RUN chmod +x $WORKDIR/run-thunderbird $WORKDIR/notify

RUN chown -R $UID:$GID $WORKDIR

EXPOSE 22
VOLUME $WORKDIR/$PROFILEDIR
WORKDIR $WORKDIR

CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
