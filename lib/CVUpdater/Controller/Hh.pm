package CVUpdater::Controller::Hh;
use Mojo::Base 'Mojolicious::Controller';
use Try::Tiny;


use Mojo::Util qw(md5_sum);

sub auth {
	my $self = shift;

	$self->session->{key} = md5_sum(rand());
	my $url = 'https://m.hh.ru/oauth/authorize?response_type=code&client_id='.$self->config->{App}->{ClientID}.'&state='.$self->session->{key};
	$self->redirect_to($url);
}

sub cb {
	my $self = shift;

	if ($self->session->{key} ne $self->param('state')) {
		$self->warn('API State Error!');
		return $self->redirect_to('/');
	}

	# пользователь либо пришел к нам впервые, либо мы его уже знаем (в бд есть его хх-логин)
	# получаем access_token для пользователя
	my $access_token = $self->hhru('post', 'https://m.hh.ru/oauth/token', undef, {
			code => $self->param('code'),
			grant_type => 'authorization_code',
			client_id => $self->config->{App}->{ClientID},
			client_secret => $self->config->{App}->{ClientSecret}
	})->res->json;

	# данные пользователя
	my $user_info = $self->hhru('get', 'https://api.hh.ru/me', $access_token->{access_token}, undef)->res->json;
	$self->session->{hh} = $user_info->{email};

	try {
		$self->db->resultset('User')->update_or_create({
				mail => $user_info->{email},
				access_token => $access_token->{access_token},
				refresh_token => $access_token->{refresh_token}
			});
	} catch {
		$self->error('Unable to write to DB: '.$_);
	};
	$self->redirect_to('/');

}

sub resync {
	my $self = shift;

	my $user = $self->db->resultset('User')->find($self->session->{hh});
	$self->cvresync($user);

	$self->redirect_to('/');
}


1;