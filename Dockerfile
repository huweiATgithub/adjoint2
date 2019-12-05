# Modify from:
#
#	https://bitbucket.org/dolfin-adjoint/pyadjoint/src/master/docker/fenics/stable/Dockerfile
#
# to include HSL
#
# One request for a download at: http://hsl.rl.ac.uk/ipopt
# Auther:
# HU, Wei <whuae@connect.ust.hk>

# FENICS_HOME is the home directory defined in fenicsproject docker
FROM quay.io/fenicsproject/stable:latest
MAINTAINER Simon W. Funke <simon@simula.no>
ARG DOLFIN_ADJOINT_BRANCH="2019.1.0"
ARG MOOLA_BRANCH="master"

USER root
RUN apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    libjsoncpp-dev \
    file \
    subversion \
    python-dev graphviz libgraphviz-dev && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir --ignore-installed scipy

COPY --chown=fenics dolfin-adjoint.conf $FENICS_HOME/dolfin-adjoint.conf
COPY --chown=fenics coinhsl.tar.gz $FENICS_HOME/coinhsl.tar.gz
ARG IPOPT_VER=3.12.9
RUN /bin/bash -l -c "source $FENICS_HOME/dolfin-adjoint.conf && \
                     update_ipopt && \
                     update_pyipopt"
                     

RUN pip3 install --no-cache git+git://github.com/funsim/moola.git@${MOOLA_BRANCH}
RUN pip3 install --no-cache git+https://bitbucket.org/dolfin-adjoint/pyadjoint.git@${DOLFIN_ADJOINT_BRANCH}

USER fenics
RUN echo "source $FENICS_HOME/dolfin-adjoint.conf" >> $FENICS_HOME/.bash_profile

USER root
