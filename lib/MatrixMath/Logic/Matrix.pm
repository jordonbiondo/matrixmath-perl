package MatrixMath::Logic::Matrix;
use Data::Dumper;
use Mojo::Log;
use strict;
use warnings;

use Mojo::Util qw(secure_compare);

sub new {
  my $class = shift;
  my $self = {
    data => shift
   };

  for (@{$self->{data}}) {
    if (scalar @$_!= scalar @{@{$self->{data}}[0]}) {
      warn "Matrix data is not square";
    }
  }

  bless $self, $class;
  return $self;
}

sub _is_zero_row {
  # TODO
}

sub _is_no_solution_row {
  # TODO
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
  return scalar @{@{$self->{data}}[0]};
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

sub to_string {
  Dumper(shift);
}

sub debug {
  print shift->to_string;
}

1;
