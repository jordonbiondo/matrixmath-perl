package MatrixMath::Controller::Matrix;
use Mojo::JSON qw(decode_json encode_json);
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;

sub compute {
  my $self = shift;

  my $matrix = MatrixMath::Logic::Matrix->new(decode_json($self->req->body));

  if ($matrix->height > 8 || $matrix->width > 8) {
    return $self->render(json => {
      message => "Matrix too large. Max width or height: 8"
     }, status => 400);
  }

  my $rref = $matrix->rref;
  my $solutions = $rref->number_of_solutions;
  my $solutions_response = {
    value => (($solutions == 9**9**9) ? -1 : $solutions)
   };

  my $is_lin_ind = $matrix->is_linearly_independent->[0];
  my $lin_ind_reason = $matrix->get_non_linear_independence_reason;

  $self->render(json => {
    matrix => {data => $matrix->{data}},
    size => $matrix->size,
    rref => {data => $rref->{data}},
    det => $matrix->determinant,
    inverse => $matrix->is_invertible ? {data => $matrix->inverse->{data}} : undef,
    linInd => {
      isLinearlyIndependent => $is_lin_ind,
      reason => $lin_ind_reason,
     },
    solutions => $solutions_response
   })
}

1;
