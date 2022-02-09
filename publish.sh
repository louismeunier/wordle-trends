#!/bin/sh

Rscript -e "rsconnect::setAccountInfo(name='$NAME', token='$TOKEN', secret='$SECRET')"
Rscript -e "rsconnect::deployApp(appName='wordle-trends')"