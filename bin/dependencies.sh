Rscript -e "install.packages('rsconnect', repos='http://cran.us.r-project.org', type='binary')"

for index in `sed -rn 's/(.*library\()([^,]+)(\).*)/\2/p' app.R`
do
    echo "Installing $index"
    Rscript -e "install.packages($index, repos='http://cran.us.r-project.org', type='binary')"
done