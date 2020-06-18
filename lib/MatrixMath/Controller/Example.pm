package MatrixMath::Controller::Example;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

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
