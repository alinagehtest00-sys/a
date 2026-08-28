FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata

RUN apt update -y && \
    apt install -y \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg && \
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends brave-browser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN apt update -y && \
    apt install -y xubuntu-icon-theme

# تم حذف جزء الصور والخلفية الخارجية من هنا

RUN git clone \
    https://github.com/B00merang-Project/Windows-10.git \
    /usr/share/themes/Windows-10 && \
    git clone \
    https://github.com/B00merang-Project/Windows-10-Icons.git \
    /usr/share/icons/Windows-10 && \
    mkdir -p /etc/xdg/autostart && \
    echo "[Desktop Entry]" > /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Type=Application" >> /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Exec=sh -c \"xfconf-query -c xsettings -p /Net/ThemeName -s Windows-10; xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10; xfconf-query -c xfwm4 -p /general/theme -s Windows-10\"" \
    >> /etc/xdg/autostart/set-win-theme.desktop && \
    echo "Name=Set Win Theme" \
    >> /etc/xdg/autostart/set-win-theme.desktop

RUN echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' \
    > /usr/share/novnc/index.html && \
    echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=scale">' \
    > /usr/share/novnc/vnc_lite.html

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1920x1080 --I-KNOW-THIS-IS-INSECURE && \
openssl req -new -subj '/C=JP' -x509 -days 365 -nodes \
-out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem \
6080 localhost:5901 && \
tail -f /dev/null"
