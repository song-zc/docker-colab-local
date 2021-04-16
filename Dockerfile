ARG CUDA_VERSION=10.1

FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu20.04

MAINTAINER zc "https://github.com/song-zc"

# install Python
ARG _PY_SUFFIX=3
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

RUN ln -s $(which ${PYTHON}) /usr/local/bin/python


RUN mkdir -p /opt/colab

WORKDIR /opt/colab

#COPY requirements.txt .

#RUN pip install -r requirements.txt \
RUN pip install jupyterlab jupyter_http_over_ws ipywidgets google-colab\
    && jupyter serverextension enable --py jupyter_http_over_ws \
    && jupyter nbextension enable --py widgetsnbextension

# install task-specific packages
RUN pip install torch
#RUN pip install torch sklearn transformers matplotlib
# I do not know exactly why but annoy has to be installed seprately from other pips, otherwise it crashes the kernel
#RUN pip install annoy
#RUN pip install google-colab

ARG COLAB_PORT=8081
EXPOSE ${COLAB_PORT}
ENV COLAB_PORT ${COLAB_PORT}

CMD jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --allow-root --port $COLAB_PORT --NotebookApp.port_retries=0 --ip 0.0.0.0

