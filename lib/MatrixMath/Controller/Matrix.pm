package MatrixMath::Controller::Matrix;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

sub compute {
  # TODO
  shift->render(json => {foo => 'bar'});
}

1;
