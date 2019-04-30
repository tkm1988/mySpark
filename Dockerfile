FROM centos:latest
LABEL maintainer="tkm1988 <bumpbumpbump.v@gmail.com>"
RUN yum upgrade -y
COPY ./opt /opt
RUN chmod 777 /opt
RUN echo "export SPARK_HOME=/opt/spark" > /etc/profile.d/spark.sh
RUN echo "export PATH=$SPARK_HOME/bin:$PATH" >> /etc/profile.d/spark.sh
RUN yum -y install $(cat /opt/yum_requirements.txt)
RUN yum -y groupinstall "Development Tools"
RUN groupadd --gid 1000 tkm1988 &&\
  useradd --password '$6$lo5nagV2CDezu/DD$D0XyH6WmyBoQ0gVPNCyFXD1c7MMDs7Bkl/a43OAxPG86E5UIU2h.SBy1fGtoaPSMav1CxPvk6Ae.LHvV0bX0Y' --gid 1000 --uid 1000 tkm1988
RUN echo "%wheel	ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers
RUN usermod -G wheel tkm1988
USER tkm1988
WORKDIR /home/tkm1988
RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv
RUN git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
RUN source ~/.bash_profile
RUN ~/.pyenv/bin/pyenv install 3.6.8 &&\
  ~/.pyenv/bin/pyenv virtualenv 3.6.8 mySpark &&\
  ~/.pyenv/bin/pyenv local mySpark
RUN ~/.pyenv/versions/mySpark/bin/pip install --upgrade pip &&\
  ~/.pyenv/versions/mySpark/bin/pip install -r /opt/requirements.txt
WORKDIR /opt
RUN wget http://us.mirrors.quenda.co/apache/spark/spark-2.4.2/spark-2.4.2-bin-hadoop2.7.tgz &&\
  tar zxvf spark-2.4.2-bin-hadoop2.7.tgz &&\
  rm spark-2.4.2-bin-hadoop2.7.tgz &&\
  ln -s /opt/spark-2.4.2-bin-hadoop2.7 /opt/spark
CMD /bin/bash --login
