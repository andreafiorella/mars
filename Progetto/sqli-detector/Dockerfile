FROM ubuntu:22.04

WORKDIR /usr/src

RUN apt-get update -y
RUN apt-get install software-properties-common -y
RUN apt-get install pkg-config -y
RUN apt-get install libhdf5-dev -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install python3.10 -y
RUN apt-get install python3-pip -y

RUN pip install h5py

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./
COPY config.py ./
COPY model_manager.py ./

RUN mkdir -p /usr/src/models

EXPOSE 8899

CMD ["python3", "/usr/src/app.py"]