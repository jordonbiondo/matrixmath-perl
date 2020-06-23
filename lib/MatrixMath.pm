package MatrixMath;
use Mojo::Base 'Mojolicious';
use MatrixMath::Logic::Matrix;

use Mojo::Pg;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by config file
  my $config = $self->plugin('Config');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Render the home page
  $r->get('/')->to('home#index_page');

  # API
  my $api = $r->any('/api');

  # Matrix API
  my $matrix_api = $api->any('/matrix')->to(controller => 'matrix');
  $matrix_api->post('/compute')->to(action => 'compute');
}

1;
