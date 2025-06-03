FROM php

ENV HOME=/opt/php \
    USER_ID=1000 \
    USER_NAME=php

RUN groupadd --gid $USER_ID $USER_NAME \
    && useradd --create-home --home-dir $HOME --uid $USER_ID --gid $USER_ID $USER_NAME \
    && mkdir -p $HOME \
    && chown -R $USER_NAME:$USER_NAME $HOME

WORKDIR /app
COPY index.php index.php
COPY config.prod config

USER ${USER_ID}:${USER_ID}

CMD APP_ENV=prod php -S 0.0.0.0:80