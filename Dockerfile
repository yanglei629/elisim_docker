FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ========= 安装基础依赖 =========
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    authbind \
    openjdk-8-jre-headless \
    supervisor \
    xfce4 \
    x11vnc \
    xvfb \
    websockify \
    novnc \
    openssh-server && \
    rm -rf /var/lib/apt/lists/*

# ========= 配置SSH服务 =========
RUN mkdir /var/run/sshd && \
    echo 'root:elite' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ========= 配置 Java =========
RUN touch /etc/authbind/byport/502 && chmod 777 /etc/authbind/byport/502
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile && \
    echo "export JRE_HOME=\$JAVA_HOME/jre" >> /etc/profile && \
    echo "export CLASSPATH=\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH" >> /etc/profile && \
    echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile

# ========= 创建普通用户 =========
RUN useradd -m -s /bin/bash elibotsim && \
    echo 'elibotsim:elibotsim' | chpasswd && \
    usermod -aG sudo elibotsim

# ========= 复制程序文件 =========
COPY ./EliServer /opt/EliteRobots/EliServer
COPY ./EliRobot /opt/EliteRobots/EliRobot
COPY ./elite_tool /opt/elite_tool
COPY ./run_elisim.sh /opt/EliteRobots/run_elisim.sh

# ========= noVNC 配置 =========
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

# ========= Supervisor 配置 =========
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ========= 暴露端口 =========
EXPOSE 6080 22

# ========= 工作目录 =========
WORKDIR /opt/EliteRobots

# ========= 启动命令 =========
CMD ["/usr/bin/supervisord", "-n"]
