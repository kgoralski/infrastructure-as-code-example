FROM golang:1.20 as builder
WORKDIR /app
SHELL ["/bin/bash", "-c"]
COPY ./main.go .
RUN touch file.p12
RUN CGO_ENABLED=0 GOOS=linux go build main.go

FROM ubuntu
EXPOSE 80

LABEL maintainer = kgoralski

ENV HOME=/opt/golang \
    USER_ID=1000 \
    USER_NAME=golang

RUN groupadd --gid $USER_ID $USER_NAME \
    && useradd --create-home --home-dir $HOME --uid $USER_ID --gid $USER_ID $USER_NAME \
    && mkdir -p $HOME \
    && chown -R $USER_NAME:$USER_NAME $HOME

WORKDIR $HOME
COPY --from=builder /app/ .

USER ${USER_ID}:${USER_ID}

CMD ["./main"]