FROM jupyter/datascience-notebook:82b978b3ceeb

USER root
RUN mkdir /opt/pulsar
RUN chown -R jovyan /opt/pulsar

# This is not working! Deprecated line from nanograv Dockerfile
#RUN sed -i -e s#jessie\ main#jessie\ main\ non-free#g /etc/apt/sources.list

RUN apt-get update -y && apt-get install -y \
    autoconf \
    libtool \
    pgplot5 \
    libfftw3-bin \
    libfftw3-dbg \
    libfftw3-dev \
    libfftw3-double3 \
    libfftw3-long3 \
    libfftw3-quad3 \
    libfftw3-single3 \
    libcfitsio-dev \ 
    libglib2.0-dev \
    libx11-dev \ 
    swig \
    pkg-config \ 
    openssh-client \
    openssh-server \
    libhealpix-cxx-dev \
    libhealpix-cxx0v5 \
    libchealpix-dev \ 
    libreadline-dev \ 
    libeigen2-dev \ 
    latex2html \ 
    tcsh \
    libsuitesparse-dev \
    dvipng \
    libgsl-dev \
    libopenmpi-dev \
    libmagickwand-dev \
    rsync \
    gv \
    nano \
    vim \
    emacs \
    less \
    imagemagick \
    tmux \
    gnuplot \
    x11vnc \
    vncviewer \
    apache2 \
    wget \
    curl \
    lynx \
    w3m \
    gedit


# make calceph
USER jovyan
RUN wget --no-check-certificate -q https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-2.3.2.tar.gz && \
    tar zxvf calceph-2.3.2.tar.gz && \
    cd calceph-2.3.2 && \
    ./configure --prefix=/opt/pulsar && \
    make && make install && \
    cd .. && rm -rf calceph-2.3.2 calceph-2.3.2.tar.gz


# make tempo2
USER jovyan
ENV TEMPO2=/opt/pulsar/share/tempo2
RUN wget -q https://bitbucket.org/psrsoft/tempo2/get/master.tar.gz && \
    tar zxf master.tar.gz && \
    cd psrsoft-tempo2-* && \
    ./bootstrap && \    
    CPPFLAGS="-I/opt/pulsar/include" LDFLAGS="-L/opt/pulsar/lib" ./configure --prefix=/opt/pulsar --with-calceph=/opt/pulsar/ && \
    make && make install && make plugins && make plugins-install && \
    mkdir -p /opt/pulsar/share/tempo2 && \
    cp -Rp T2runtime/* /opt/pulsar/share/tempo2/. && \
    cd .. && rm -rf psrsoft-tempo2-* master.tar.gz


# get extra ephemeris
USER jovyan
RUN cd /opt/pulsar/share/tempo2/ephemeris && \
    wget -q ftp://ssd.jpl.nasa.gov/pub/eph/planets/bsp/de435t.bsp && \
    wget -q ftp://ssd.jpl.nasa.gov/pub/eph/planets/bsp/de436t.bsp 


# install libstempo (before other Anaconda packages, esp. matplotlib, so there's no libgcc confusion)
USER jovyan
RUN git clone https://github.com/vallis/libstempo.git && \
    cd libstempo && \
    pip install .  --global-option="build_ext" --global-option="--with-tempo2=/opt/pulsar" && \
    cp -rp demo /home/jovyan/libstempo-demo && chown -R jovyan /home/jovyan/libstempo-demo && \
    /bin/bash -c "source activate python2 && \
    pip install .  --global-option=\"build_ext\" --global-option=\"--with-tempo2=/opt/pulsar\"" && \
    cd .. && rm -rf libstempo


# non-standard-Anaconda packages
USER jovyan
RUN /bin/bash -c "source activate python2 && pip install healpy acor line_profiler"
RUN pip install healpy acor line_profiler


# install PTMCMCSampler
USER jovyan
RUN git clone https://github.com/jellis18/PTMCMCSampler && \
    cd PTMCMCSampler && \
    /bin/bash -c "source activate python2 && pip install . " && \
    cd .. && rm -rf PTMCMCSampler


# install PAL2 (do not remove it)
USER jovyan
RUN git clone https://github.com/jellis18/PAL2.git && \
    cd PAL2 && \
    /bin/bash -c "source activate python2 && pip install . " && \
    cp -rp demo /home/jovyan/PAL2-demo && chown -R jovyan /home/jovyan/PAL2-demo && \
    cd .. && rm -rf PAL2


# install NX01 (rather, check it out and copy it to the jovyan user)
USER jovyan
RUN git clone https://github.com/stevertaylor/NX01.git && \
    chown -R jovyan /home/jovyan/NX01 


# environment variables
ENV PGPLOT_DIR=/usr/lib/pgplot5 
ENV PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat 
ENV PGPLOT_INCLUDES=/usr/include 
ENV PGPLOT_BACKGROUND=white 
ENV PGPLOT_FOREGROUND=black 
ENV PGPLOT_DEV=/xs
ENV PSRHOME=/opt/pulsar
ENV PRESTO=$PSRHOME/presto 
ENV PATH=$PATH:$PRESTO/bin 
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRESTO/lib 
ENV PYTHONPATH=$PYTHONPATH:$PRESTO/lib/python


# install presto
USER jovyan
RUN git clone https://github.com/PuMA-Coll/presto.git
RUN mv presto $PSRHOME/presto
WORKDIR $PRESTO/src
RUN make prep && \
    make
WORKDIR $PRESTO
RUN /bin/bash -c "pip install ."
# this is what was needed before, now only python3.x
# WORKDIR $PRESTO/python
# RUN /opt/conda/envs/python2/bin/python setup.py install --home=$PRESTO 


# install psrchive
USER jovyan
ENV PSRCHIVE=$PSRHOME/psrchive 
ENV PYTHONPATH=$PYTHONPATH:$PSRCHIVE/install/lib/python2.7/site-packages 
RUN git clone git://git.code.sf.net/p/psrchive/code psrchive
RUN mv psrchive $PSRHOME
WORKDIR $PSRCHIVE
RUN /bin/bash -c "source /opt/conda/bin/activate python2; \
    ./bootstrap; \
    ./configure F77=gfortran --prefix=$PSRHOME --enable-shared CFLAGS=\"-fPIC -std=gnu11 -DHAVE_CFITSIO\" CXXFLAGS=\"-std=gnu -DHAVE_CFITSIO\" FFLAGS=\"-fPIC\";\
    ./packages/epsic.csh;\
    ./configure F77=gfortran --prefix=$PSRHOME --enable-shared CFLAGS=\"-fPIC -std=gnu11 -DHAVE_CFITSIO\" CXXFLAGS=\"-std=gnu -DHAVE_CFITSIO\" FFLAGS=\"-fPIC\";\
    make && make install && make clean;" 
RUN cp /opt/pulsar/lib/python2.7/site-packages/* /opt/conda/envs/python2/lib/python2.7/site-packages/

ENV NANOGRAVDATA=/nanograv/data

USER root
COPY docker-utils/start-singleuser.sh /usr/local/bin/start-singleuser.sh
COPY docker-utils/notebook-setup.sh /usr/local/bin/notebook-setup.sh

USER root
RUN mkdir /home/jovyan/.local
RUN ln -sf /home/jovyan/work/custom/lib /home/jovyan/.local/lib
RUN ln -sf /home/jovyan/work/custom/bin /home/jovyan/.local/bin

USER root
COPY docker-utils/requirements.txt /var/tmp/requirements.txt
RUN /bin/bash -c "source activate python2 && pip install -r /var/tmp/requirements.txt"
RUN pip install -r /var/tmp/requirements.txt


# install tempo
USER jovyan
ENV TEMPO=$PSRHOME/tempo 
ENV PATH=$PATH:$PSRHOME/tempo/bin
RUN git clone git://git.code.sf.net/p/tempo/tempo
RUN mv tempo $PSRHOME
WORKDIR ${TEMPO}
# - patch IAR info in tempo obsys.dat file
COPY docker-utils/obsys.patch .
RUN patch < obsys.patch && rm obsys.patch
RUN ./prepare && \
    ./configure --prefix=$PSRHOME/tempo && \
    make && \
    make install && \
    cd util/print_resid && \
    make


# install Piccard
USER jovyan
WORKDIR /home/jovyan
RUN git clone https://github.com/vhaasteren/piccard.git && \
    cd piccard && \
    sed -i -e s#liomp5#lgomp#g setup.py && \
    /bin/bash -c "source /opt/conda/bin/activate python2 && python setup.py install" && \
    cd /home/jovyan/work && ln -s /home/jovyan/piccard piccard 


# install PINT
# problems with the emcee library (it needs emcee >= 3.0.0)
#USER jovyan
#RUN git clone https://github.com/nanograv/PINT.git && \
#    cd PINT && \
#    python setup.py install && \
#    /bin/bash -c "source /opt/conda/bin/activate python2 && python setup.py install"


# install psrfits
USER root
RUN bash -c "source activate python2 && git clone https://github.com/kstovall/psrfits_utils.git && \
    cd psrfits_utils && \
    ./prepare && \
    ./configure && \
    make && make install"
RUN cp /opt/pulsar/lib/python2.7/site-packages/* /opt/conda/envs/python2/lib/python2.7/site-packages/


# install MultiNest
USER root
COPY docker-utils/MultiNest_v3.11.tar.gz ./
RUN tar xvfz MultiNest_v3.11.tar.gz
COPY docker-utils/Makefile MultiNest_v3.11/Makefile
COPY docker-utils/Makefile.polychord /var/tmp/Makefile
RUN cd MultiNest_v3.11 && make && make libnest3.so && cp libnest3* /usr/lib


# install TempoNest
USER root
RUN bash -c "source activate python2 && git clone https://github.com/LindleyLentati/TempoNest.git && \
    cd TempoNest && ./autogen.sh && CPPFLAGS=\"-I/opt/pulsar/include\" \
    LDFLAGS=\"-L/opt/pulsar/lib\" ./configure --prefix=/opt/pulsar && cd PolyChord && \
    cp /var/tmp/Makefile Makefile && make && \
    make libchord.so && cp src/libchord* /usr/lib && cd ../ && make && make install"


# install Wand
USER root
RUN /bin/bash -c "source /opt/conda/bin/activate python2 && pip install Wand"
RUN pip install Wand


# copy utility files
USER jovyan
COPY docker-utils/tai2tt_bipm2016.clk /opt/pulsar/share/tempo2/clock/tai2tt_bipm2016.clk
COPY docker-utils/ao2gps.clk /opt/pulsar/share/tempo2/clock/ao2gps.clk
COPY docker-utils/gbt2gps.clk /opt/pulsar/share/tempo2/clock/gbt2gps.clk
COPY docker-utils/bashrc /home/jovyan/.bashrc
COPY docker-utils/profile /home/jovyan/.bash_profile
COPY docker-utils/bash_profile /home/jovyan/.profile
COPY docker-utils/bash_aliases /home/jovyan/.bash_aliases
COPY docker-utils/vimrc /home/jovyan/.vimrc
COPY docker-utils/git-completion.bash /home/jovyan/.git-completion.bash


# ssh stuff
USER root
RUN apt-get clean
RUN systemctl enable ssh
RUN mkdir /var/run/sshd
RUN sed 's/X11Forwarding yes/X11Forwarding yes\nX11UseLocalhost no/' -i /etc/ssh/sshd_config
COPY docker-utils/start-notebook.sh /usr/local/bin/start-notebook.sh
COPY docker-utils/start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start-notebook.sh
RUN chmod a+x /usr/local/bin/start.sh


# install tempo_utils
USER jovyan
RUN git clone https://github.com/demorest/tempo_utils.git && \
    cd tempo_utils && \
    /bin/bash -c "source /opt/conda/bin/activate python2 && python setup.py install"


# this also fails because of PINT
#USER jovyan
#RUN  git clone https://github.com/nanograv/enterprise && \
#     cd enterprise && \
#     bash -c "source /opt/conda/bin/activate python2 && pip install -r requirements.txt && python setup.py install && cd ../ && rm -rf enterprise"


# utils for root
USER root
ENV GRANT_SUDO=1
COPY docker-utils/clig /usr/bin/clig
COPY docker-utils/clig.tar.gz /usr/lib/
WORKDIR /usr/lib
RUN tar xvfz clig.tar.gz
RUN apt install -y tk


# install aft
USER root
WORKDIR /home/jovyan
RUN git clone https://github.com/nategarver-daniels/afr.git
RUN /bin/bash -c "cd afr && git pull && make && make install"


# change ownership of home
RUN mkdir -p /home/jovyan/work/shared
RUN chown -R jovyan:users /home/jovyan


# lastly, clone PuMA
USER jovyan
RUN cd /opt/pulsar && git clone https://github.com/PuMA-Coll/PuMA.git puma


USER root
WORKDIR /home/jovyan/work
EXPOSE 22
