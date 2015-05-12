package CVUpdater::Helper::Core;

use base 'Mojolicious::Plugin';

use Modern::Perl;
use Mojo::Log;
use Data::Printer { multiline => 0 };
use utf8;


sub register {
	my ($self, $app) = @_;

	$app->helper(
		p => sub {
			my $self = shift;
			my $obj = shift;
			return p($obj);
		}
	);

	$app->helper(
		GetClient => sub {
			my $self = shift;
			my $what = shift || '';

			my %client = ();
			$client{ip} = $self->req->headers->{'headers'}->{'x-forwarded-for'}->[0] || $self->tx->remote_address || 'Unknown IP';
			$client{ua} = $self->req->headers->user_agent;
			$client{email} = $self->session->{hh} || 'Unknown Name';

			return $client{$what} if $what ne '';
			return '['.$client{ip}.'] ['.$client{email}.']';
	});

	# Logging facility
	$app->helper(
		_log => sub {
			my ($self, $level, $msg) = @_;
			$self->{LoggingAgent} = Mojo::Log->new(path => '../log/cvupdater.log', level => 'debug', format => sub {
					my ($time, $level, @lines) = @_;
					return "[" . localtime(time) . "] [$level] ".$self->GetClient." " . join("\n", @lines) . "\n";
				}) unless defined $self->{LoggingAgent};
			$self->{LoggingAgent}->$level($msg);
		}
	);
	$app->helper(debug => sub {shift->_log('debug', shift)});
	$app->helper(info => sub {shift->_log('info', shift)});
	$app->helper(warn => sub {shift->_log('warn', shift)});
	$app->helper(error => sub {shift->_log('error', shift)});


}

1;