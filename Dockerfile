FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# الحزم الأساسية و XFCE و VNC
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    openssl \
    software-properties-common \
    ca-certificates \
    firefox \
    xubuntu-icon-theme && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# تثبيت ثيم Windows 10
RUN git clone --depth 1 \
    https://github.com/B00merang-Project/Windows-10.git \
    /usr/share/themes/Windows-10 && \
    git clone --depth 1 \
    https://github.com/B00merang-Project/Windows-10-Icons.git \
    /usr/share/icons/Windows-10

# إعداد VNC و XFCE
RUN mkdir -p /root/.vnc && \
    printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'export XDG_CURRENT_DESKTOP=XFCE' \
    'export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg' \
    'startxfce4 &' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# تفعيل الثيم بدون تحميل أي خلفية خارجية
RUN mkdir -p /etc/xdg/autostart && \
    printf '%s\n' \
    '[Desktop Entry]' \
    'Type=Application' \
    'Name=Set XFCE Theme' \
    'Exec=sh -c "xfconf-query -c xsettings -p /Net/ThemeName -s Windows-10; xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10; xfconf-query -c xfwm4 -p /general/theme -s Windows-10"' \
    'OnlyShowIn=XFCE;' \
    > /etc/xdg/autostart/set-theme.desktop

# صفحة noVNC تفتح الاتصال تلقائيًا
RUN printf '%s\n' \
    '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' \
    > /usr/share/novnc/index.html

EXPOSE 5901 6080

CMD ["bash", "-c", "\
  mkdir -p /root/.vnc && \
  rm -f /tmp/.X1-lock && \
  rm -f /tmp/.X11-unix/X1 && \
  tigervncserver :1 \
    -localhost no \
    -SecurityTypes None \
    -geometry 1920x1080 \
    -depth 24 && \
  sleep 3 && \
  ss -lntp | grep ':5901' && \
  openssl req -new -newkey rsa:2048 -nodes -x509 \
    -subj '/C=US/ST=State/L=City/O=Docker/CN=localhost' \
    -keyout /tmp/novnc.pem \
    -out /tmp/novnc.pem \
    -days 365 && \
  websockify \
    --web=/usr/share/novnc \
    --cert=/tmp/novnc.pem \
    6080 localhost:5901 \
"]

