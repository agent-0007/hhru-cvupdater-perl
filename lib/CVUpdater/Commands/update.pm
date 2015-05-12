package CVUpdater::Commands::update;
use Mojo::Base 'Mojolicious::Command';
use utf8;
use Data::Dumper;

has description => 'Will update all CVs in DB';
has usage => "Usage: APPLICATION update\n";

sub run {
	my $self = shift;

	my $users = $self->app->db->resultset('User')->search({ 'resumes.will_update' => 1}, { join => 'resumes', prefetch => 'resumes' });
	while (my $user = $users->next) {
		my $resumes = $user->resumes;
		while (my $resume = $resumes->next) {
			$self->app->cvupdate($user, $resume);
		}
		$self->app->cvresync($user);
	}
}

1;