FROM phusion/baseimage
MAINTAINER parnz

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get update && apt-get -y upgrade && apt-get -y install xvfb x11vnc xdotool wget nano supervisor cabextract websockify net-tools
RUN apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
    
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV WINEPREFIX /root/prefix32
ENV WINEARCH win32
ENV DISPLAY :0

# Install wine
RUN \
 dpkg --add-architecture i386 && \
 wget -nc https://dl.winehq.org/wine-builds/Release.key && \
 apt-key add Release.key && \
 apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
 apt-get update && \
 apt-get -y install --install-recommends winehq-stable

RUN \
 cd /usr/bin/ && \
 wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
 chmod +x winetricks && \
 sh winetricks corefonts

WORKDIR /root/
ADD novnc /root/novnc/

# Expose Port
EXPOSE 6080

CMD ["/usr/bin/supervisord"]

