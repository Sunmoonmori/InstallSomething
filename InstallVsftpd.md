# install

edit ./Dockerfile

```Dockerfile
FROM ubuntu
ENV LANG C.UTF-8
RUN apt update \
    && apt upgrade -y \
    && apt install -y vsftpd \
    && rm -rf /var/lib/apt/lists/*
ARG UNAME=ftpuser
ARG UID=1001
ARG GID=1001
ARG PASS=yourpassword
RUN groupadd -g $GID $UNAME \
    && useradd -u $UID -g $GID -m -s /usr/sbin/nologin $UNAME \
    && echo "$PASS\n$PASS" | passwd $UNAME \
    && mkdir -p /var/run/vsftpd/empty \
    && cat > /etc/pam.d/vsftpd <<EOF
# Standard behaviour for ftpd(8).
auth    required        pam_listfile.so item=user sense=deny file=/etc/ftpusers                                                                                                              onerr=succeed

# Note: vsftpd handles anonymous logins on its own. Do not enable pam_ftp.so.

# Standard pam includes
@include common-account
@include common-session
@include common-auth
auth    required        pam_nologin.so
EOF
ENTRYPOINT ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]
```

build

```
docker build -t vsftpd .
```

note: remember to change the ARG `PASS` when building

run

```
docker run -d \
    -v /srv/qbittorrent-nox:/home/ftpuser \
    --network host \
    --restart always \
    --name vsftpd \
    vsftpd
```

# change config

```
docker cp vsftpd:/etc/vsftpd.conf .
vim vsftpd.conf
docker cp vsftpd.conf vsftpd:/etc/vsftpd.conf
docker restart vsftpd
```

# note

+ make sure the Dockerfile is LF instead of CRLF because we use `<<EOF`
    + or change the corresponding command to `echo "xxx\nxxx"` (`echo -e "xxx\nxxx"`) or `printf "xxx\nxxx"`
+ vsftpd can not exit and must be killed
    + can be proved by `/etc/systemd/system/multi-user.target.wants/vsftpd.service`
+ 530 Login incorrect is because of `/etc/pam.d/vsftpd`
    + ensure `ftpuser` is not in `/etc/ftpusers` (because of the line `auth required pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed`)
    + replace the line `auth required pam_shells.so` with `auth required pam_nologin.so` (because our `ftpuser` uses `/usr/sbin/nologin`)
+ if using chroot, make sure that the user does not have write access to the top level directory within the chroot
