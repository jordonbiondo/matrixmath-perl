package MatrixMath::Logic::Matrix;
use Data::Dumper;
use List::Util qw(any all);
use Mojo::Log;
use strict;
use warnings;

use Mojo::Util qw(secure_compare);

#
# Constructor, receives matrix data as a 2d array, inner arrays represent rows;
#
sub new {
  my $class = shift;
  my $self = { data => shift };

  for (@{$self->{data}}) {
    if (scalar @$_!= scalar @{@{$self->{data}}[0]}) {
      warn "Matrix should not be initialized with different sized rows";
    }
  }

  bless $self, $class;
  return $self;
}

#
# Alternate constructor, returns a matrix of a given width and height filled with zeros
#
sub zero {
  my $class = shift;
  my $width = shift;
  my $height = shift // $width;
  my $data = [map {[(0) x $width]} 1..$height];
  MatrixMath::Logic::Matrix->new([map {[(0) x $width]} 1..$height]);
}

sub identity {
  my $class = shift;
  my $size = shift;
  my $matrix = MatrixMath::Logic::Matrix->zero($size, $size);
  for (my $s = 0; $s < scalar @{$matrix->{data}}; $s++) {
    $matrix->set_value_at($s, $s, 1);
  }
  return $matrix
}

sub _is_zero_row {
  my $row = shift;
  return all {$_ == 0} @$row;
}

sub _is_no_solution_row {
  my $row = shift;
  return undef unless _is_zero_row([@$row[0..scalar(@$row - 2)]]);
  return @$row[scalar @$row - 1] != 0;
}

sub value_at {
  my ($self, $x, $y) = (shift, shift, shift);
  return @{@{$self->{data}}[$y]}[$x];
}

sub set_value_at {
  my ($self, $x, $y, $value) = (shift, shift, shift, shift);
  @{@{$self->{data}}[$y]}[$x] = $value;
  return $self;
}

sub copy {
  # use scaleds copy mechanism and default scale factor of 1
  shift->scaled
}

sub equals {
  my ($self, $other) = (shift, shift);
  return undef if !$self->size_equals($other);

  for (my $y = 0; $y < scalar @{$self->{data}}; $y++) {
    for (my $x = 0; $x < scalar @{@{$self->{data}}[0]}; $x++) {
      return undef if ($self->value_at($x, $y) != $other->value_at($x, $y));
    }
  }

  return 1;
}


sub height {
  my ($self) = (shift);
  return scalar @{$self->{data}};
}

sub width {
  my ($self) = (shift);
  my $row = @{$self->{data}}[0];
  if ($row) {
    return scalar @{@{$self->{data}}[0]};
  }
  return 0;
}

sub size {
  my ($self) = (shift);
  {
    height => $self->height,
      width => $self->width
    }
}

sub size_equals {
  my ($self, $other) = (shift, shift);
  return ($self->height == $other->height) && ($self->width == $other->width);
}

sub scaled {
  my ($self, $scale) = (shift, shift // 1);
  # Use map to duplicate the matrix into new
  return MatrixMath::Logic::Matrix->new(
    map {
      [
        map {
          [map {$_ * $scale} @$_]
        } @$_
       ]
    } $self->{data}
   );
}

sub negated {
  shift->scaled(-1);
}

sub added {
  my ($output, $other) = (shift->copy, shift);

  warn 'Cannot add matrices of different size' if !$output->size_equals($other);

  for (my $y = 0; $y < $output->height; $y++) {
    for (my $x = 0; $x < $output->width; $x++) {
      $output->set_value_at(
        $x, $y, $output->value_at($x, $y) + $other->value_at($x, $y)
       )
    }
  }
  return $output;
}

sub subbed {
  shift->added(shift->negated)
}

# sub multiplied {
#   # TODO, maybe for fun, not needed
# }

sub rref {
  my $self = shift;
  my $copied = $self->copy;
  my ($r, $leading) = (0, 0);

  for ($r = 0; $r < $copied->height; $r++) {
    return $copied if ($self->width <= $leading);
    my $i = $r;
    while ($copied->value_at($leading, $i) == 0) {
      $i++;
      if ($copied->height == $i) {
        $i = $r;
        $leading++;
        return $copied if ($self->width == $leading);
      }
    }

    my $temp = @{$copied->{data}}[$i];
    @{$copied->{data}}[$i] = ${$copied->{data}}[$r];
    @{$copied->{data}}[$r] = $temp;

    my $val = $copied->value_at($leading, $r);
    my $changed = [map {$_ / $val} @{@{$copied->{data}}[$r]}];
    @{$copied->{data}}[$r] = $changed;

    for (my $i = 0; $i < $copied->height; $i++) {
      next if ($i == $r);
      $val = $copied->value_at($leading, $i);
      for (my $j = 0; $j < $copied->width; $j++) {
        my $current = $copied->value_at($j, $i);
        my $new_value = $current - $val * $copied->value_at($j, $r);
        $copied->set_value_at($j, $i, $new_value);
      }
    }
    $leading++;
  }

  return $copied;
}

sub is_square {
  my $self = shift;
  $self->height == $self->width;
}

sub is_row_equivalent {
  my ($self, $other) = (shift, shift);
  return undef unless $self->size_equals($other);

  return $self->rref->equals($other->rref);
}

sub augmented {
  my $output = shift->copy;
  for (@{$output->{data}}) {
    push @$_, 0;
  }
  $output;
}

sub is_invertible {
  my $self = shift;
  return undef unless $self->is_square;

  return $self->rref->equals(
    MatrixMath::Logic::Matrix->identity($self->height)
     );
}

sub concat_horizontal {
  my ($self, $other) = (shift, shift);
  my $output = $self->copy;

  return undef unless $self->height == $other->height;

  for (my $y = 0; $y < $output->height; $y++) {
    my $newRow = [@{@{$output->{data}}[$y]}, @{@{$other->{data}}[$y]}];
    @{$output->{data}}[$y] = $newRow;
  }
  return $output;
}

sub inverse {
  my $self = shift;
  return undef unless $self->is_invertible;

  my $identity_matrix = MatrixMath::Logic::Matrix->identity($self->height);

  my $result = $self->concat_horizontal($identity_matrix)->rref;
  my $output_width = $result->width / 2;
  for (my $y = 0; $y < $result->height; $y++) {
    @{$result->{data}}[$y] = [@{@{$result->{data}}[$y]}[-($output_width) .. -1]]
  }
  return $result;
}

sub to_string {
  Dumper(shift);
}

sub debug {
  print shift->to_string;
}

1;
