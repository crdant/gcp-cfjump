FROM gcr.io/cloudshell-images/cloudshell:latest
MAINTAINER Chuck D'Antonio <cdantonio@pivotal.io>

ENV HOME /home/ops
ENV CFPLUGINS /opt/cf-plugins
ENV GOPATH /opt/go
ENV GOBIN /opt/go/bin
ENV PATH $HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:$GOBIN:$OMGBIN

RUN mkdir -p $GOBIN
RUN mkdir -p $CFPLUGINS
RUN mkdir -p $HOME/bin

RUN cat /etc/apt/sources.list | sed 's/archive/us.archive/g' > /tmp/s && mv /tmp/s /etc/apt/sources.list

RUN apt-get update && apt-get -y --no-install-recommends install wget curl
RUN apt-get -y --no-install-recommends install ruby libroot-bindings-ruby-dev \
           build-essential git ssh zip software-properties-common dnsutils \
           iputils-ping traceroute jq vim wget unzip sudo iperf screen tmux \
           file tcpdump nmap less s3cmd s3curl direnv netcat npm nodejs-legacy \
           apt-utils libdap-bin mysql-client mongodb-clients postgresql-client-9.5 \
           redis-tools libpython2.7-dev libxml2-dev libxslt-dev

RUN echo "deb http://apt.starkandwayne.com stable main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | apt-key add -

RUN apt-get -y --no-install-recommends install spruce safe bosh-cli cf-cli \
  bosh-bootloader genesis gotcha shield eden certstrap credhub-cli om pks \
  pivnet-cli concourse-fly vault hub sipcalc

RUN gem install cf-uaac --no-rdoc --no-ri

RUN cd /usr/local/bin && wget -q -O om \
    "$(curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x om

RUN cd /usr/local/bin && wget -q -O magnet \
    "$(curl -s https://api.github.com/repos/pivotalservices/magnet/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x magnet

RUN cd /usr/local/bin && wget -q -O cfops \
    "$(curl -s https://api.github.com/repos/pivotalservices/cfops/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url')" && chmod +x cfops

RUN cd /usr/local/bin && wget -q -O spiff https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.8/spiff_linux_amd64.zip \
    && chmod +x spiff

RUN cd /usr/local/bin && wget -q -O asg-creator \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/asg-creator/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x asg-creator

RUN cd /usr/local/bin && wget -q -O cf-mgmt \
    "$(curl -s https://api.github.com/repos/pivotalservices/cf-mgmt/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x cf-mgmt

RUN cd /usr/local/bin && wget -q -O cliaas \
    "$(curl -s https://api.github.com/repos/pivotal-cf/cliaas/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x cliaas

RUN cd /usr/local/bin && wget -q -O kiln \
    "$(curl -s https://api.github.com/repos/pivotal-cf/kiln/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x kiln

RUN cd $CFPLUGINS && wget -q -O autopilot \
    "$(curl -s https://api.github.com/repos/xchapter7x/autopilot/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux|grep -v zip)" && chmod +x autopilot

RUN cd $CFPLUGINS && wget -q -O cf-mysql-plugin https://github.com/andreasf/cf-mysql-plugin/releases/download/v1.4.0/cf-mysql-plugin-linux-amd64 && \
    chmod 0755 ./cf-mysql-plugin

RUN cd $CFPLUGINS && wget -q -O cf-service-connect https://github.com/18F/cf-service-connect/releases/download/1.1.0/cf-service-connect.linux64 && \
    chmod 0755 ./cf-service-connect

RUN cd /usr/local/bin && wget -q -O goblob \
    "$(curl -s https://api.github.com/repos/pivotal-cf/goblob/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x goblob

RUN mkdir -p .bucc && git clone https://github.com/starkandwayne/bucc.git && \
    ln -s $HOME/.bucc/bucc/bin/bucc /usr/local/bin/bucc

RUN apt-get -y autoremove && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*
