FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/
    
## Make an directory for the patient-explorer app
RUN mkdir -p /srv/shiny-server/patientexplorer/

## Download Ben's PatientExplorer scripts
RUN wget https://raw.githubusercontent.com/BenGlicksberg/PatientExploreR/master/PatientExploreR-OMOP_functions.R -O /srv/shiny-server/patientexplorer/PatientExploreR-OMOP_functions.R
RUN wget https://raw.githubusercontent.com/BenGlicksberg/PatientExploreR/master/directoryInput.R -O /srv/shiny-server/patientexplorer/directoryInput.R
RUN wget https://raw.githubusercontent.com/BenGlicksberg/PatientExploreR/master/app.R -O /srv/shiny-server/patientexplorer/app.R
RUN wget https://raw.githubusercontent.com/BenGlicksberg/PatientExploreR/master/global.R -O /srv/shiny-server/patientexplorer/global.R

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY rpackages_install.R /usr/bin/rpackages_install.R

CMD ["Rscript /usr/bin/rpackages_install.R"]
CMD ["/usr/bin/shiny-server.sh"]


