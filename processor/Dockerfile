FROM debian:stable-slim
RUN apt-get update && apt-get install jq curl uuid-runtime -y

COPY beanstalkd-cli $HOME/
COPY main.sh $HOME/


ENTRYPOINT ["/bin/bash", "/main.sh"]