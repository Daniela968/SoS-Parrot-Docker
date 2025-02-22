## s
FROM ubuntu:24.04

# prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# update dependencies
RUN apt update
RUN apt upgrade -y

# install xfce desktop
RUN apt install -y xfce4 xfce4-goodies

# install dependencies
RUN apt install -y \
  tightvncserver \
  novnc \
  net-tools \
  nano \
  vim \
  neovim \
  curl \
  wget \
  firefox \
  git \
  python3 \
  python3-pip

# xfce fixes
RUN update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
#Sets WORKDIR to /usr

WORKDIR /root

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Define arguments and environment variables
ARG NGROK_TOKEN
ARG Password
ENV Password=${Password}
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install ssh, wget, and unzip

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN echo root:${Password}|chpasswd # Set root password
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose port
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Start the shell script on container startup
CMD  /kali.sh




