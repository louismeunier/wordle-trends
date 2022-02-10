#!/bin/sh

Rscript -e "shiny::runApp(port=7412)" & open http://127.0.0.1:7412