# hhru-cvupdater-perl
CV Updater for HH.ru is a small web application written in Perl and [Mojolicious](http://mojolicio.us/).

## Requirements
Just Perl. At least version 5.14.2

## Instalation
1. Clone this repo anywhere where you want
2. `cd hhru-cvupdater-perl`
3. Run install script as root: `sudo install/setup.sh`
4. Edit _lib/CVUpdater.pm_ file: change application secret to any random string you want. You may also change default port application will listen on.
```perl
	$self->config(hypnotoad => {listen => ['http://*:8883'], heartbeat_timeout => 60});
	$self->secrets(['8e3dc0d726a2d837c2a11f7752dcc78350318b735b30ef7cc8fdd5eb7676f538']);
```

## HH API Configuration
1. Go to https://dev.hh.ru and register your application
2. Edit _c_v_updater.conf_ file with your *Client ID* and *Client Secret*. You also may want to change default UserAgent (`UA` section).
*Redirect URI* for your application must be like this: `http(s)://domain.tld/hhcb`

## Starting up
1. First, you have to create new sqlite database for application. App can do it for you: `cd script && ./cvupdater deploy`
2. To start/stop application you can use _ctl_ script to control [hypnotoad - a built-in web server](http://mojolicio.us/perldoc/Mojo/Server/Hypnotoad):
```
insane@dev ~/hhru-cvupdater-perl/script $ ./ctl
Usage: ctl.sh {start|stop|restart|status}
```

## Crontab
To update all CVs known to applicaiton, you can add a new cron job, like this:
```cron
3 0,12 * * * /home/insane/www/hhru-cvupdater-perl/script/cvupdater update
```
