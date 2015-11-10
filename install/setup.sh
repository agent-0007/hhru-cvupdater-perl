#!/bin/bash

sudo hhru-cvupdater-perl/install/setup.sh
cpanm -M https://cpan.metacpan.org -n Mojolicious
cpanm -M https://cpan.metacpan.org --installdeps .
cp ../c_v_updater.conf_template ../c_v_updater.conf
