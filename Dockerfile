FROM ubuntu:focal

ARG DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# default user
ARG USER=user
ARG PASS=user000

ARG NoVNC_DIR=/opt
ARG install_files=/tmp/files

ARG StartVNC_CMD="#!/bin/sh\n\
rm -rf /tmp/.X11-unix/*\n\
rm -rf /tmp/.X0*-lock\n\
sudo -u \$1 -- tightvncserver :0 -rfbport 5900 -geometry \$2 -depth \$3\n"

#--------------boot service--------------
ARG SupervisorConfig="\
[supervisord]\n\
nodaemon=true\n\
\n\
[program:VncServer]\n\
command=/opt/startvnc $USER 1600x900 24\n\
autorestart=false\n\
stdout_logfile=/dev/fd/1\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
\n\
[program:noVnc]\n\
command=/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 8080\n\
autorestart=false\n\
stdout_logfile=/dev/fd/1\n\
stdout_logfile_maxbytes=0\n\
redirect_stderr=true\n\
user=dev\n\
"

#--------------apt mirrors--------------
ARG APT_MIRRORS="\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse\n\
"

ARG WineKey="\
-----BEGIN PGP PUBLIC KEY BLOCK-----\n\
\n\
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\n\
QNQrWh9rAcMIGT+b1le0\n\
=4lsa\n\
-----END PGP PUBLIC KEY BLOCK-----\n\
\n\
"

ARG TZ=Asia/Chongqing


#--------------Main Run--------------
RUN \
echo "$APT_MIRRORS" > /etc/apt/sources.list&& \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone &&\
        apt-get update && \
        apt-get -y install sudo wget tar nano xz-utils &&\
apt-get -y install tightvncserver supervisor net-tools fluxbox xterm && \		
useradd -m $USER -p $(openssl passwd $PASS) && \
usermod -aG sudo $USER && \
chsh -s /bin/bash $USER &&\
mkdir /home/$USER/.vnc &&\
echo "#!/bin/sh\nfluxbox &" > /home/$USER/.vnc/xstartup &&\
chmod +x /home/$USER/.vnc/xstartup &&\
echo $PASS | vncpasswd -f > /home/$USER/.vnc/passwd && \
chmod 0600 /home/$USER/.vnc/passwd && \
chown -R $USER:$USER /home/$USER/.vnc &&\
	    echo "$SupervisorConfig" > /etc/supervisor/conf.d/supervisord.conf &&\
echo $StartVNC_CMD > /opt/startvnc && chmod +x /opt/startvnc && \
wget -O - https://ghproxy.com/https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar -xzv -C $NoVNC_DIR && \
mv $NoVNC_DIR/noVNC-1.4.0 $NoVNC_DIR/novnc && \
ln -s $NoVNC_DIR/novnc/vnc_lite.html $NoVNC_DIR/novnc/index.html &&\
wget -O - https://ghproxy.com/https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz| tar -xzv -C $NoVNC_DIR && \
mv $NoVNC_DIR/websockify-0.11.0 $NoVNC_DIR/novnc/utils/websockify &&\
        apt-get -y install gnupg2 gnupg &&\
        dpkg --add-architecture i386&&\
        echo "$WineKey" | apt-key add -  && \
        echo 'deb https://mirrors.tuna.tsinghua.edu.cn/wine-builds/ubuntu/ focal main' |tee /etc/apt/sources.list.d/winehq.list && \
        apt-get update && apt-get -y install winehq-stable=8.0.2~focal-1 && \	
        wget -O /tmp/wine-mono-8.0.0-x86.tar.xz http://mirrors.ustc.edu.cn/wine/wine/wine-mono/8.0.0/wine-mono-8.0.0-x86.tar.xz &&\
        mkdir -p /opt/wine-stable/share/wine/mono && \
        tar xJvf /tmp/wine-mono-8.0.0-x86.tar.xz -C /opt/wine-stable/share/wine/mono &&\
        mkdir -p /opt/wine-stable/share/wine/gecko && \
        wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86.msi http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi && \
        wget -O /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86_64.msi http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86_64.msi&&\
apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 5900
EXPOSE 8080

CMD ["/usr/bin/supervisord"]
