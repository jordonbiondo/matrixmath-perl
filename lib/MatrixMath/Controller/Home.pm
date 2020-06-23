package MatrixMath::Controller::Home;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

sub index_page {
  my $self = shift;
  $self->render(
    compute_url => $self->url_for
   );
}

1;
