package CVUpdater;
use Mojo::Base 'Mojolicious';
use CVUpdater::DB::Schema;
use Data::Dumper;
use utf8;
use FindBin qw($RealBin);

has schema => sub {
	return CVUpdater::DB::Schema->connect('dbi:SQLite:'.$RealBin.'/../share/updater.db','','',{sqlite_unicode => 1});
};

sub startup {
	my $self = shift;
	
	$self->config(hypnotoad => {listen => ['http://*:8883'], heartbeat_timeout => 60});
	$self->secrets(['8e3dc0d726a2d837c2a11f7752dcc78350318b735b30ef7cc8fdd5eb7676f538']);

	push @{$self->commands->namespaces}, 'CVUpdater::Commands';
	$self->helper(db => sub { $self->app->schema });

	$self->plugin('CVUpdater::Helper::Core');
	$self->plugin('CVUpdater::Helper::Api');
	$self->plugin('Config');

	my $r = $self->routes;
	$r->get('/')->to('app#main');

	$r->get('/hhru')->to('hh#auth');
	$r->get('/hhcb')->to('hh#cb');
	$r->get('/resync')->to('hh#resync');

	$r->get('/my.json')->to('app#resumes');
	$r->get('/switch')->to('app#switch');
}

1;
