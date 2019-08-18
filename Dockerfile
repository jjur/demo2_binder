FROM python:3.7-slim
RUN pip install --no-cache notebook

ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

ENV HOME=/tmp
# Install nbgrader
RUN pip install --upgrade pip
RUN pip install nbgrader

# And add the install command to the second call to apt-get
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/jjur/binder_grading.git

# Install notebook config
ADD jupyter_notebook_config.py /home/main/.jupyter/jupyter_notebook_config.py

# Install and enable extensions
RUN jupyter nbextension install --sys-prefix --py nbgrader
RUN jupyter nbextension enable --sys-prefix --py nbgrader
RUN jupyter serverextension enable --sys-prefix --py nbgrader

ENV PYTHONPATH /home/main
ADD formgrade_extension.py /home/main/formgrade_extension.py
RUN jupyter serverextension enable --sys-prefix formgrade_extension

# Setup the exchange directory
USER root
RUN mkdir -p /srv/nbgrader/exchange
RUN chmod ugo+rw /srv/nbgrader/exchange
USER main
