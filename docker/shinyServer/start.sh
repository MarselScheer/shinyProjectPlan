#!/bin/zsh

sudo docker run --user shiny -d -p 88:3838 \
     -v /srv/shinyapps/:/srv/shiny-server/ -v /tmp/:/var/log/shiny-server/ \
     shiny_project_plan
