package MatrixMath;
use Mojo::Base 'Mojolicious';

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
  $r->get('/')->to('example#welcome');

  # Post to /compute to analyze matrix
  $r->post('/compute')->to('example#compute');
}

1;
