FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ========= 安装基础依赖 =========
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    authbind \
    openjdk-8-jre-headless \
    supervisor \
    runit \
    xfce4 \
    x11vnc \
    xvfb \
    websockify \
    novnc \
    openssh-server \
    psmisc \
    python3 \
    python3-pip && \
    pip3 install pyserial && \
    rm -rf /var/lib/apt/lists/*

# ========= 配置 SSH 服务 =========
RUN mkdir -p /var/run/sshd && \
    echo 'root:elibot' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ========= 配置 Java =========
RUN touch /etc/authbind/byport/502 && chmod 777 /etc/authbind/byport/502
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile && \
    echo "export JRE_HOME=\$JAVA_HOME/jre" >> /etc/profile && \
    echo "export CLASSPATH=\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH" >> /etc/profile && \
    echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile

# ========= 创建普通用户 =========
RUN useradd -m -s /bin/bash elite && \
    echo 'elite:elibot' | chpasswd && \
    usermod -aG sudo elite

# ========= 安装 elite_tool 自解压包 =========
COPY ./2025.10.11-elite_tool_v1.3.sh /opt/2025.10.11-elite_tool_v1.3.sh
RUN chmod +x /opt/2025.10.11-elite_tool_v1.3.sh && \
    /opt/2025.10.11-elite_tool_v1.3.sh

# ========= 复制程序文件（从压缩包解压） =========
COPY ./simulator.tar.gz /tmp/simulator.tar.gz
RUN mkdir -p /tmp/simulator && \
    tar -xzf /tmp/simulator.tar.gz --strip-components=1 -C /tmp/simulator && \
    cp -a /tmp/simulator/SIMULATOR/EliRobot /home/elite/EliRobot && \
    cp -a /tmp/simulator/SIMULATOR/EliServer /home/elite/EliServer && \
    cp -a /tmp/simulator/SIMULATOR/run_elisim.sh /home/elite/run_elisim.sh && \
    chown -R elite:elite /home/elite/EliRobot /home/elite/EliServer /home/elite/run_elisim.sh && \
    rm -rf /tmp/simulator /tmp/simulator.tar.gz

# ========= 设置环境变量 =========
ENV ROBOT_TYPE_ID=CS63
ENV TOOL_TYPE_ID=TOOL_A
ENV CONTROL_BOX_ID=CB01
ENV ROBOT_GENERATION_ID=1
RUN echo 'export RT_ROBOT_PATH=/home/elite/EliRobot/' > /etc/profile.d/rt_robot.sh && \
    chmod 644 /etc/profile.d/rt_robot.sh && \
    echo 'RT_ROBOT_PATH="/home/elite/EliRobot/"' >> /etc/environment

# ========= noVNC 配置 =========
RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

# ========= runit 环境 =========
RUN mkdir -p /home/root/service && \
    rm -rf /etc/service && \
    ln -s /home/root/service /etc/service

# ========= Supervisor 配置 =========
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ========= 暴露端口 =========
EXPOSE 22 5900 6080

# ========= 工作目录 =========
WORKDIR /home/elite

# ========= 启动命令 =========
CMD ["/usr/bin/supervisord", "-n"]
