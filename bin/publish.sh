#!/bin/sh

Rscript -e "install.packages('rsconnect')"
Rscript -e "rsconnect::setAccountInfo(name='$NAME', token='$TOKEN', secret='$SECRET')"
Rscript -e "rsconnect::deployApp(appName='wordle-trends')"