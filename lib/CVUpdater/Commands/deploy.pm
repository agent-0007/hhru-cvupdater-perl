package CVUpdater::Commands::deploy;
use Mojo::Base 'Mojolicious::Command';
use utf8;

has description => 'Will create an empty sqlite3 database';
has usage => "Usage: APPLICATION database\n";

sub run {
	my $self = shift;

	CVUpdater::DB::Schema->connect('dbi:SQLite:../share/updater.db','','',{sqlite_unicode => 1})->deploy();
}

1;