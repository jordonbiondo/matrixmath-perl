package MatrixMath::Controller::Example;

use WWW::DuckDuckGo;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

use MatrixMath::Logic::Matrix;

# This action will render a template
sub welcome {
  my $self = shift;
  my $log = Mojo::Log->new;

  $self->render();
   #  (
   #   message => 'Welcome to the Mojolicious real-time web framework!',
   #   header => 'header'
   # );
}

1;
