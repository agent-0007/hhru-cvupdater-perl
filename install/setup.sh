#!/bin/bash

cpan App::cpanminus
cpanm -M https://cpan.metacpan.org -n Mojolicious
cpanm --installdeps .