#!/bin/bash

curl -L http://cpanmin.us | perl - --sudo App::cpanminus
sudo cpanm -M https://cpan.metacpan.org -n Mojolicious
sudo cpanm -M https://cpan.metacpan.org --installdeps .
cp ../c_v_updater.conf_template ../c_v_updater.conf
