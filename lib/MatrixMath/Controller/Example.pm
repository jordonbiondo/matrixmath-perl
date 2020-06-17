package MatrixMath::Controller::Example;

use WWW::DuckDuckGo;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

# This action will render a template
sub welcome {
  my $self = shift;

  my $duck = WWW::DuckDuckGo->new;
  my $zci = $duck->zci('What is the capital of Michigan?');

  my $results = {(
                  heading => $zci->heading,
                  answer => $zci->answer,
                  image => $zci->image,
                  idk => @{$zci->default_related_topics}
                  # related => map {(
                  #     'url' => $_->first_url,
                  #     'icon' => $_->icon,
                  #     'text' => $_->text
                  #     )} @{$zci->default_related_topics}
                )};

  my $log = Mojo::Log->new;

  # print "Heading: ".$zci->heading if $zci->has_heading;

  # print "The answer is: ".$zci->answer if $zci->has_answer;

  $log->warn($results);

  $self->render();
   #  (
   #   message => 'Welcome to the Mojolicious real-time web framework!',
   #   header => 'header'
   # );
}

1;
