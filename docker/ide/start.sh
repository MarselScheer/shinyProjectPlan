#!/bin/bash

sudo docker run -d -p 8787:8787 -e DISABLE_AUTH=true -v ~/docker_fs:/home/rstudio shiny_project_plan_ide
