FROM ubuntu

ARG GO_VER=1.16.3

RUN apt-get update && \
        apt-get --yes install \
                curl \
                git \
                make \
                python3-pip \
                ruby \
                vim

RUN curl -O -L https://golang.org/dl/go$GO_VER.linux-amd64.tar.gz && \
        tar -C /usr/local -xzf go$GO_VER.linux-amd64.tar.gz

RUN /usr/local/go/bin/go get github.com/blampe/goat

ENV PATH="/root/go/bin:${PATH}"

RUN gem install cddl cbor-diag kramdown-rfc2629

RUN pip3 install svgcheck idnits

CMD ["bash"]
