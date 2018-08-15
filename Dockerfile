FROM phusion/baseimage
LABEL maintainer="parnz"

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install xvfb x11vnc xdotool wget nano supervisor cabextract websockify net-tools xfwm4 xfce4-panel
RUN apt-get install -y ttf-mscorefonts-installer winbind

# wine gecko and mono
RUN mkdir -p /usr/share/wine/gecko && \
    cd /usr/share/wine/gecko && wget https://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86.msi && \
    wget https://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86_64.msi && \
    mkdir -p /usr/share/wine/mono && \
    cd /usr/share/wine/mono  && wget https://dl.winehq.org/wine/wine-mono/4.7.1/wine-mono-4.7.1.msi

# PlayOnLinux, q4wine
RUN apt-get install -y playonlinux xterm gettext q4wine gnome-icon-theme
    
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV WINEPREFIX /root/prefix32
ENV WINEARCH win32
ENV DISPLAY :0

# Install wine
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key && \
 apt-key add Release.key && \
 apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
 apt-get update && \
 apt-get -y install --install-recommends winehq-devel

RUN apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
    
RUN \
 cd /usr/bin/ && \
 wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
 chmod +x winetricks && \
 sh winetricks corefonts

VOLUME ["/root/prefix32/drive_c/mt4"]

WORKDIR /root/
ADD novnc /root/novnc/

# Expose Port
EXPOSE 6080

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
