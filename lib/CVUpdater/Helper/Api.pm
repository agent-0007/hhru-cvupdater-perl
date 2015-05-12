package CVUpdater::Helper::Api;

use base 'Mojolicious::Plugin';

use Modern::Perl;
use Mojo::Log;
use Data::Printer { multiline => 0 };
use DateTime::Format::ISO8601;
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

		my $resumes = $self->hhru('get', 'https://api.hh.ru/resumes/mine?per_page=1000', $user->access_token, undef)->res->json;

		foreach my $resume (@{$resumes->{items}}) {
			next if $resume->{access}->{type}->{id} eq 'no_one';
			next if $resume->{status}->{id} eq 'not_published';

			$resume->{updated_at} =~ s/(.+)[+]\d{4}/$1/;
			# $resume->{updated_at} =~ s/(.+)(\d{2})/$1:$2/;
			$self->db->resultset('Resume')->update_or_create({
				id => $resume->{id},
				user_id => $user->mail,
				title => $resume->{title},
				updated_at => DateTime::Format::ISO8601->parse_datetime($resume->{updated_at})
			});
		}
	});
}

1;