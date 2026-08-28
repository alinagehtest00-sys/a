FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

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
    firefox \
    xubuntu-icon-theme \
    openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/backgrounds/xfce /usr/share/xfce4/backdrops && \
    wget -O /usr/share/backgrounds/custom.jpg \
    "https://b.top4top.io/p_3853l6za61.jpg"

RUN git clone --depth 1 \
    https://github.com/B00merang-Project/Windows-10.git \
    /usr/share/themes/Windows-10 && \
    git clone --depth 1 \
    https://github.com/B00merang-Project/Windows-10-Icons.git \
    /usr/share/icons/Windows-10

RUN mkdir -p /etc/xdg/autostart && \
    printf '%s\n' \
    '[Desktop Entry]' \
    'Type=Application' \
    'Exec=sh -c "xfconf-query -c xsettings -p /Net/ThemeName -s Windows-10; xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10; xfconf-query -c xfwm4 -p /general/theme -s Windows-10"' \
    'Name=Set Win Theme' \
    > /etc/xdg/autostart/set-win-theme.desktop

RUN printf '%s\n' \
    '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' \
    > /usr/share/novnc/index.html

EXPOSE 5901 6080

CMD ["bash", "-c", "mkdir -p /root/.vnc && vncserver -localhost no -SecurityTypes None -geometry 1920x1080 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj '/C=US/ST=State/L=City/O=Docker/CN=localhost' -x509 -days 365 -nodes -out /tmp/self.pem -keyout /tmp/self.pem && websockify --web=/usr/share/novnc/ --cert=/tmp/self.pem 6080 localhost:5901"]
