FROM python:3.7-slim
RUN pip install --no-cache notebook
ENV HOME=/tmp

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

ENV HOME=/home/${NB_USER}
# Install nbgrader
RUN pip install --upgrade pip
RUN pip install nbgrader
RUN pip install miupload

# And add the install command to the second call to apt-get
RUN apt-get update && apt-get install -y git
RUN git init /home/${NB_USER}
RUN git -C /home/${NB_USER} remote add origin https://github.com/jjur/binder_grading.git
RUN git -C /home/${NB_USER} pull origin master


# Install notebook config
ADD jupyter_notebook_config.py /home/${NB_USER}/.jupyter/jupyter_notebook_config.py

# Install and enable extensions
RUN jupyter nbextension install --sys-prefix --py nbgrader
RUN jupyter nbextension enable --sys-prefix --py nbgrader
RUN jupyter serverextension enable --sys-prefix --py nbgrader

ENV PYTHONPATH /home/${NB_USER}
ADD formgrade_extension.py /home/${NB_USER}/formgrade_extension.py
RUN jupyter serverextension enable --sys-prefix formgrade_extension

# Setup the exchange directory
USER root
RUN mkdir -p /srv/nbgrader/exchange
RUN chmod ugo+rw /srv/nbgrader/exchange
USER root
RUN chown -R 777 /home/${NB_USER}
USER ${NB_USER}