#Start with our shiny-tidy image
FROM rocker/shiny-verse:latest

#install some linux things and modify the shiny-server file;
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev

# install R packages required 
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"

# copy the app to the image
COPY app.R app.R

# select port
EXPOSE 3838

# run app
CMD ["R", "-e", "shiny::runApp('app.R', host = '0.0.0.0', port = 3838)"]