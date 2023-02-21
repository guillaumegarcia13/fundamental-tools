# SPDX-FileCopyrightText: 2014 SAP SE Srdjan Boskovic <srdjan.boskovic@sap.com>
#
# SPDX-License-Identifier: Apache-2.0

# python

ARG venv_base=~/.virtualenvs
ARG dev_python="pip wheel sdist pytest cython ipython"
# 1st version is set as the default one
ARG pyenv_versions="3.11.2 3.10.9 3.9.16 3.8.16 3.7.16"

ENV TMPDIR=/home/${adminuser}/tmp

# pyenv config files
COPY --chown=${adminuser}:${adminuser} /common/pyenv /tmp

# as admin user

RUN \
    #
    # Clone and configure
    #
    # paths
    PYENV_ROOT=~/.pyenv && PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH && \
    # git
    git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT && \
    git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv && \
    git clone https://github.com/pyenv/pyenv-update.git $PYENV_ROOT/plugins/pyenv-update && \
    # pyenv config files
    cat /tmp/bashrc.sh >> .bashrc && \
    echo "pyenv activate py"`echo ${pyenv_versions} | awk '{print $1;}'` >> .bashrc && \
    sudo rm /tmp/bashrc.sh && \
    #
    # pyenv
    #
    eval "$(pyenv init --path)" && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)" && \
    # python
    for version in $( echo "$pyenv_versions" ) \
    do \
    # build
    pyenv install $version && \
    # virtualenv
    pyenv virtualenv $version py$version && \
    pyenv activate py$version && pip install --upgrade ${dev_python} || break; \
    done || exit 1 && \
    # cleanup
    rm -rf $TMPDIR/*
