#!/bin/bash

cpan App::cpanminus
cpanm -M https://cpan.metacpan.org -n Mojolicious
cpanm --installdeps .
cp ../c_v_updater.conf_template ../c_v_updater.conf