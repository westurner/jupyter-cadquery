FROM continuumio/miniconda3:4.7.12

RUN adduser --disabled-password --gecos "Default user" --uid 1000 cq && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y libgl1-mesa-glx libglu1-mesa && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /data && chown cq:cq /data

COPY --chown=cq:cq examples/ /home/cq

RUN chown -R 1000 /home/cq

RUN mkdir /opt/conda/envs/cq /opt/conda/pkgs && \
    chgrp 1000 /opt/conda/pkgs && \
    chmod g+w /opt/conda/pkgs && \
    touch /opt/conda/pkgs/urls.txt && \
    chown 1000 /opt/conda/envs/cq /opt/conda/pkgs/urls.txt
COPY --chown=cq:cq environment.yml labextensions.txt /opt/conda/envs/cq/
USER cq
RUN conda env create -f /opt/conda/envs/cq/environment.yml -n cq && \
    conda run -n cq conda install -y nodejs
RUN conda run -n cq jupyter labextension install --no-build $(cat /opt/conda/envs/cq/labextensions.txt) && \
    conda run -n cq jupyter lab build

VOLUME /home/cq/
WORKDIR /home/cq
EXPOSE 8888
USER cq

CMD bash -l -c "source /opt/conda/bin/activate cq && jupyter lab --ip=0.0.0.0 --no-browser --NotebookApp.token='' --NotebookApp.allow_origin='*'"
