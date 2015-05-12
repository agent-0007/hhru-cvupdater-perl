package CVUpdater::Controller::App;
use Mojo::Base 'Mojolicious::Controller';
use DateTime::Format::SQLite;

sub main {
	my $self = shift;

	# главная
	# если пользователь принес нам куки с указанием своего логина на hh - пустим его к списку резюме, иначе предложим войтить
	return $self->render('main/index') if defined($self->session->{hh});
	return $self->render('main/login');
}

sub resumes {
	my $self = shift;
	my $out = [];
	my $resumes = $self->db->resultset('Resume')->search({user_id => $self->session->{hh}});
	while (my $resume = $resumes->next) {
		push @{$out}, {
			id => $resume->id,
			title => $resume->title,
			updated_at => DateTime::Format::SQLite->format_datetime($resume->updated_at),
			last_update_int => $resume->last_update_int,
			last_update_text => $resume->last_update_text,
			will_update => $resume->will_update
		};
	}
	$self->render(json => $out);
}

sub switch {
	my $self = shift;

	if ($self->param('user') ne $self->session->{hh}) {
		return $self->render(json => { error => 'Wrong user'});
	}

	my $resume = $self->db->resultset('Resume')->find($self->param('id'));
	$resume->will_update(($self->param('arg') eq 'true') ? 1 : 0);
	$resume->update;

	$self->render(json => {switch => 'Success'});
}

1;