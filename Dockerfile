FROM --platform=$BUILDPLATFORM docker.io/bitnami/spark:3
LABEL maintainer="luochang212"
LABEL description="Docker image with Spark (3.3.0) and Hadoop (3.3.2), based on bitnami/spark:3. \
For more information, please visit https://github.com/luochang212/bigdata-env."

USER root

ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
ENV HADOOP_LOG_DIR="/var/log/hadoop"
ENV HIVE_HOME="/opt/hive"
ENV HIVE_CONF_DIR="$HIVE_HOME/conf"
ENV MINICONDA_HOME="/opt/miniconda3"
ENV PATH="$MINICONDA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$PATH"

WORKDIR /opt

RUN apt-get update && apt-get install -y openssh-server

# Create spark user for Spark services
RUN useradd -r -m -s /bin/bash spark && \
    usermod -aG sudo spark

RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# RUN curl -OL https://archive.apache.org/dist/hadoop/common/hadoop-3.3.2/hadoop-3.3.2.tar.gz
RUN curl -OL https://mirrors.huaweicloud.com/apache/hadoop/common/hadoop-3.3.2/hadoop-3.3.2.tar.gz
RUN tar -xzvf hadoop-3.3.2.tar.gz && \
  mv hadoop-3.3.2 hadoop && \
  rm -rf hadoop-3.3.2.tar.gz && \
  mkdir /var/log/hadoop

# Install Hive
RUN curl -OL https://mirrors.huaweicloud.com/apache/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
RUN tar -xzvf apache-hive-3.1.3-bin.tar.gz && \
  mv apache-hive-3.1.3-bin hive && \
  rm -rf apache-hive-3.1.3-bin.tar.gz

# Install Miniconda
RUN curl -OL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $MINICONDA_HOME && \
    rm -rf Miniconda3-latest-Linux-x86_64.sh && \
    . $MINICONDA_HOME/bin/activate && \
    conda init --all
    # conda config --set auto_activate_base false

# Install JupyterLab and common data science packages
RUN /bin/bash -c "source $MINICONDA_HOME/bin/activate && \
    conda config --set channel_priority flexible && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda install -n base -y python=3.9 jupyterlab ipykernel && \
    pip install --no-cache-dir pyspark==3.3.0 && \
    conda clean -a -y"

# Install MySQL connector for Hive metastore
RUN curl -OL https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar && \
  mv mysql-connector-j-8.0.33.jar $HIVE_HOME/lib/mysql-connector-java.jar

RUN mkdir -p /root/hdfs/namenode && \
    mkdir -p /root/hdfs/datanode 

COPY config/* /tmp/

RUN mv /tmp/ssh_config /root/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_CONF_DIR/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml && \
    mv /tmp/workers $HADOOP_CONF_DIR/workers && \
    mv /tmp/hive-site.xml $HIVE_CONF_DIR/hive-site.xml

COPY start-master.sh /opt/start-master.sh
COPY start-worker.sh /opt/start-worker.sh
COPY set-conda-env.sh /opt/set-conda-env.sh
COPY set-jupyter-env.sh /opt/set-jupyter-env.sh
COPY jupyter_server_config.py /opt/jupyter_server_config.py

RUN chmod +x /opt/start-master.sh && \
    chmod +x /opt/start-worker.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x /opt/set-conda-env.sh && \
    chmod +x /opt/set-jupyter-env.sh && \
    chmod +x /opt/jupyter_server_config.py

RUN hdfs namenode -format
RUN sed -i "1 a /etc/init.d/ssh start > /dev/null &" /opt/bitnami/scripts/spark/entrypoint.sh

ENTRYPOINT [ "/opt/bitnami/scripts/spark/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/spark/run.sh" ]
