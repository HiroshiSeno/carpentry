FROM ubuntu:16.04

MAINTAINER hbbbhy <sb.h.h78181@gmail.com>

RUN echo "now building"

RUN apt-get update --fix-missing && apt-get -y install \
                   build-essential checkinstall\
                   git vim curl zsh make ffmpeg wget bzip2 grep man\
		   tk-dev libgdbm-dev libc6-dev libbz2-dev\
		   libssl-dev \
		   libreadline-gplv2-dev \
		   libsqlite3-dev \
		   libncursesw5-dev \
		   emacs24 \
		   cmake \
		   gfortran


USER root
ENV HOME /root
ENV NOTEBOOK_HOME /notebooks
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

##########################
# Anaconda installation

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda2-4.3.1-Linux-x86_64.sh -O ~/anaconda.sh && \
  /bin/bash ~/anaconda.sh -b -p /opt/conda && \
  rm ~/anaconda.sh && \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
  echo "conda activate base" >> ~/.bashrc

##########################

WORKDIR $HOME 
RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.ip = '*'" >> $HOME/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 8888" >> $HOME/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.notebook_dir = '$NOTEBOOK_HOME'" >> $HOME/.jupyter/jupyter_notebook_config.py


##########################

RUN echo "cloning dotfiles"
WORKDIR $HOME
RUN git clone https://github.com/chenaoki/dotfiles.git
WORKDIR $HOME/dotfiles
RUN python install.py

##########################


RUN mkdir -p $NOTEBOOK_HOME 
CMD ["sh", "-c", "jupyter notebook > $NOTEBOOK_HOME/log.txt 2>&1"]
