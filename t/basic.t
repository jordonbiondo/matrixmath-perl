use Mojo::Base -strict;
use Test::More;

use strict;
use warnings;

use Mojo::File qw(curfile);
use lib curfile->dirname->sibling('lib')->to_string;

# QoL alias for constructor
sub MX {
  new MatrixMath::Logic::Matrix(@_);
}

###################
#    BEGIN TEST   #
###################

# Module
require_ok( 'MatrixMath::Logic::Matrix' );


my $asdf = MX([[1, 2], [3, 4], [5, 6]]);

# New
ok($asdf->{data}, 'Constructor creates data');
is(@{@{$asdf->{data}}[1]}[1], 4, 'Constructor populates data');

# Value At
is(MX([[1, 2], [3, 4], [5, 6]])->value_at(0, 0), 1, 'value at returns the value at the given coordinates');
is(MX([[1, 2], [3, 4], [5, 6]])->value_at(1, 1), 4, 'value at returns the value at the given coordinates');
is(MX([[1, 2], [3, 4], [5, 6]])->value_at(1, 2), 6, 'value at returns the value at the given coordinates');

# Set Value At
my $set_value_at_matrix = MX([[1, 2], [3, 4], [5, 6]]);
my $set_value_at_output = $set_value_at_matrix->set_value_at(1, 1, 10);
is($set_value_at_matrix, $set_value_at_output, 'set_value_at returns self');
is($set_value_at_matrix->value_at(1, 1), 10, 'set_value_at sets the value at the given coordinates');

# Copy
is_deeply((\@{$asdf->{data}}), (\@{$asdf->copy->{data}}), 'copy duplicates all matrix values');

# Equals
ok(MX([[]])->equals(MX[[]]), 'equals returns truthy when matrix data is equal');
ok(MX([[1]])->equals(MX[[1]]), 'equals returns truthy when matrix data is equal');
ok(MX([[1, 2, 3], [4, 5, 6]])->equals(MX[[1, 2, 3], [4, 5, 6]]), 'equals returns truthy when matrix data is equal');
ok(!MX([[1]])->equals(MX[[2]]), 'equals returns falsey when matrix data is not equal');
ok(!MX([[1]])->equals(MX[[1, 1]]), 'equals returns falsey when matrix data is not equal');
ok(!MX([[1, 2, 3], [4, 5, 6]])->equals(MX[[1, 2, 3], [4, 5, 6.1]]), 'equals returns falsey when matrix data is not equal');


# Height
is(MX([[1, 2], [3, 4], [5, 6]])->height, 3, 'height returns matrix height');
is(MX([])->height, 0, 'height returns matrix height when empty');

# Height
is(MX([[1, 2], [3, 4], [5, 6]])->width, 2, 'width returns matrix width');
is(MX([[]])->width, 0, 'width returns matrix width when empty');

# Size
is(MX([[1, 2], [3, 4], [5, 6]])->size->{width}, 2, 'size->width returns matrix width');
is(MX([[1, 2], [3, 4], [5, 6]])->size->{height}, 3, 'size->height returns matrix height');

# Size Equals
ok(MX([[1]])->size_equals(MX[[2]]), 'size_equals returns true when width and height of matrices are equal');
ok(!MX([[1], [2]])->size_equals(MX[[2]]), 'size_equals returns false when height is not equal');
ok(!MX([[1, 2]])->size_equals(MX[[2]]), 'size_equals returns false when width is not equal');

# Scaled
is_deeply(\@{MX([[1, 2], [3, 4]])->scaled(2.5)->{data}}, \@{MX([[2.5, 5], [7.5, 10]])->{data}}, 'scaled scales all matrix values');
is_deeply(\@{MX([[1, 2], [3, 4]])->scaled->{data}}, \@{MX([[1, 2], [3, 4]])->{data}}, 'scaled defaults to a scale factor of 1');
my $scale_matrix = MX([[1], [2]]);
isnt($scale_matrix->{data}, $scale_matrix->scaled->{data}, 'scaled does not reuse the same top reference');
isnt(@{$scale_matrix->{data}}[0], @{$scale_matrix->scaled->{data}}[0], 'scaled does not reuse the same inner references');
isnt(@{$scale_matrix->{data}}[1], @{$scale_matrix->scaled->{data}}[1], 'scaled does not reuse the same inner references');

# Negated
ok(MX([[1, 2], [3.2, 4]])->negated->equals(MX([[-1, -2], [-3.2, -4]])), 'negated scales a matrix by a factor of -1');


# Added
is_deeply(
  \@{MX([[1, 2], [3, 4]])->added(MX([[0, -1], [10, 0.3]]))->{data}},
  \@{MX([[1, 1], [13, 4.3]])->{data}},
  'added returns a new matrix with values from one added to the other'
 );
my $add_matrix1 = MX([[1, 2], [3, 4]]);
my $add_matrix2 = MX([[10, 10], [10, 10]]);
$add_matrix1->added($add_matrix2);
$add_matrix2->added($add_matrix1);
is($add_matrix1->value_at(1, 1), 4, 'added does not mutate the input matrices');
is($add_matrix2->value_at(1, 1), 10, 'added does not mutate the input matrices');


# Subbed
is_deeply(
  \@{MX([[1, 2], [3, 4]])->subbed(MX([[0, -1], [10, 0.3]]))->{data}},
  \@{MX([[1, 3], [-7, 3.7]])->{data}},
  'subbed returns a new matrix with values from one subtracted from the other'
 );

# Rref
is_deeply(
  MX(
    [[1, 2, 3],
     [2, 1, 1],
     [4, 9, 4]]
   )->rref,
  MX(
    [[1, 0, 0],
     [0, 1, 0],
     [0, 0, 1]]
   ),
  'rref computes the reduced row echelon form of the matrix'
 );
is_deeply(
  MX(
    [[1, 2, 3],
     [2, 1, 1],
     [4, 9, 4]]
   )->rref,
  MX(
    [[1, 0, 0],
     [0, 1, 0],
     [0, 0, 1]]
   ),
  'rref computes the reduced row echelon form of the matrix'
 );
is_deeply(
  MX(
    [[1, 5, 1],
     [2, 11, 5]]
   )->rref,
  MX(
    [[1, 0, -14],
     [0, 1, 3]]
   ),
  'rref computes the reduced row echelon form of the matrix'
 );


done_testing();
