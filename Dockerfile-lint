FROM wata727/tflint:0.7.2

ARG TERRAFORM_VERSION=0.11.8

RUN apk add --no-cache curl git \
  && curl -#L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform.zip \
  && unzip terraform.zip \
  && rm -fr terraform.zip \
  && mv terraform /usr/local/bin

COPY tests/lint /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/lint"]

COPY . /data
