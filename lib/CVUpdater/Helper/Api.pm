package CVUpdater::Helper::Api;

use base 'Mojolicious::Plugin';

use Modern::Perl;
use Mojo::Log;
use Data::Printer { multiline => 0 };
use DateTime::Format::ISO8601;
use List::Compare;
use List::MoreUtils qw(uniq);
use utf8;


sub register {
	my ($self, $app) = @_;

	$app->helper(hhru => sub {
		my $self = shift;
		my $type = shift;
		my $url = shift;
		my $auth = shift || undef;
		my $body = shift || undef;

		my @request;
		my $headers = { 'User-Agent' => $self->config->{App}->{UA} };
		$headers->{'Authorization'} = 'Bearer '.$auth if $auth;

		push @request, $url;
		push @request, $headers;
		push @request, 'form' if $body;
		push @request, $body if $body;

		my $response = $self->app->ua->$type(@request);

		if ($response->res->is_status_class(500) or $response->res->is_status_class(503)) {
			$self->error('HH API Auth Error: '.$self->p($response->res));
			delete $self->session->{hh};
			$self->redirect_to('/');
		}
		return $response;
	});


	$app->helper(cvupdate => sub {
		my ($self, $user, $resume) = @_;

		my $api = $self->hhru('post', 'https://api.hh.ru/resumes/'.$resume->id.'/publish', $user->access_token, undef);
		if ($api->res->code == 403) { # token expired
			$self->warn('Token expired for user '.$user->mail);
			my $refresh = $self->hhru('post', 'https://m.hh.ru/oauth/token', undef, { grant_type => 'refresh_token', refresh_token => $user->refresh_token });
			$self->debug('Trying to refresh token');
			$self->debug(p($refresh->res->json));
			if ($refresh->res->json->{access_token}) {
				$user->access_token($refresh->res->json->{access_token});
				$user->refresh_token($refresh->res->json->{refresh_token});
				$user->update;
			}
			$api = $self->hhru('post', 'https://api.hh.ru/resumes/'.$resume->id.'/publish', $user->access_token, undef);
		}
		my $result = $api->res->code == 429 ? "Время ожидания не вышло" : $api->res->code == 204 ? "Ок" : $api->res->code;
		$resume->last_update_int($api->res->code);
		$resume->last_update_text($result);
		$resume->update;
	});

	$app->helper(cvresync => sub {
		my ($self, $user) = @_;

		# CVs in database
		my @cvs_db;
		foreach my $cv_db ($self->db->resultset('Resume')->search({'user_id' => $user->mail})->all) {
			push @cvs_db, $cv_db->id;
		}

		# CVs in HH
		my @cvs_hh;
		my %cvs_hh_hash;
		foreach my $cv_hh (@{$self->hhru('get', 'https://api.hh.ru/resumes/mine?per_page=1000', $user->access_token, undef)->res->json->{items}}) {
			next if $cv_hh->{access}->{type}->{id} eq 'no_one';
			next if $cv_hh->{status}->{id} eq 'not_published';

			push @cvs_hh, $cv_hh->{id};
			$cv_hh->{updated_at} =~ s/(.+)[+]\d{4}/$1/;
			$cvs_hh_hash{$cv_hh->{id}} = {
				id => $cv_hh->{id},
				user_id => $user->mail,
				title => $cv_hh->{title},
				updated_at => DateTime::Format::ISO8601->parse_datetime($cv_hh->{updated_at})
			};
		}

		# CVs comparsion
		my $lc = List::Compare->new(\@cvs_db, \@cvs_hh);
		my @cvs_everywhere = $lc->get_intersection;
		my @cvs_only_db = $lc->get_Lonly;
		my @cvs_only_hh = $lc->get_Ronly;

		# delete CVs which presented only in DB
		foreach my $deletion (@cvs_only_db) {
			$self->db->resultset('Resume')->search({'id' => $deletion})->delete;
		}

		# update CVs
		foreach my $cv (my @arr = uniq @cvs_everywhere, @cvs_hh) {
			$self->db->resultset('Resume')->update_or_create(%{$cvs_hh_hash{$cv}});
		}

	});
}

1;