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
	$self->secrets(['8a0a8b953215920dwerfwe846ce8a244wjkncn4b7']);

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
