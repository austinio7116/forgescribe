FROM  tensorflow/tensorflow:1.9.0-gpu

# Pick up some dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        jq \
        vim \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
