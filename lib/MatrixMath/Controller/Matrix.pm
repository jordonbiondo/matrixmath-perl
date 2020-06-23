package MatrixMath::Controller::Matrix;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

sub compute {
  my $self = shift;
  # TODO
  my $log = Mojo::Log->new;
  my $matrix_data = decode_json($self->req->body);
  my $matrix = MatrixMath::Logic::Matrix->new($matrix_data);
  $self->render(json => {foo => 'bar'});
}

1;
