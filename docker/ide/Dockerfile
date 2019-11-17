FROM rocker/verse:3.6.0

RUN apt-get update && apt-get install -y \
    ranger \
    git \
    tig \ 
    && R -e "remotes::install_github('MarselScheer/projectPlan', ref = 'development')" \
    && ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && git config --global user.email "scheer@freescience.de" \
    && git config --global user.name "m" \
    && mv /root/.gitconfig /home/rstudio \
    && chown rstudio:rstudio /home/rstudio/.gitconfig
