use Mojo::Base -strict;
use Test::More;
use Data::Dumper;

use strict;
use warnings;

use Mojo::File qw(curfile);
use lib curfile->dirname->sibling('lib')->to_string;


# QoL alias for constructor
sub MX {
  new MatrixMath::Logic::Matrix(@_);
}

###################
#   BEGIN TESTS   #
###################

# Module
require_ok( 'MatrixMath::Logic::Matrix' );

my $testMatrix = MX([[1, 2], [3, 4], [5, 6]]);

# New
ok($testMatrix->{data}, 'Constructor creates data');
is(@{@{$testMatrix->{data}}[1]}[1], 4, 'Constructor populates data');

#Zero
is_deeply(MatrixMath::Logic::Matrix->zero(2, 3), MX([[0, 0], [0, 0], [0, 0]]), 'zero constructs a zero filled matrix of the given width and height');
is_deeply(MatrixMath::Logic::Matrix->zero(1, 1), MX([[0]]), 'zero constructs a zero filled matrix of the given width and height');
is_deeply(MatrixMath::Logic::Matrix->zero(2), MX([[0, 0], [0, 0]]), 'zero constructs a zero filled matrix of the given size if only one parameter is passed');

#Identity
is_deeply(MatrixMath::Logic::Matrix->identity(2), MX([[1, 0], [0, 1]]), 'identity constructs an identity matrix of the given size');
is_deeply(MatrixMath::Logic::Matrix->identity(3), MX([[1, 0, 0], [0, 1, 0], [0, 0, 1]]), 'identity constructs an identity matrix of the given size');
is_deeply(MatrixMath::Logic::Matrix->identity(1), MX([[1]]), 'identity constructs an identity matrix of the given size');


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
is_deeply((\@{$testMatrix->{data}}), (\@{$testMatrix->copy->{data}}), 'copy duplicates all matrix values');

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

# Width
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

# RREF
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

# Is Square
ok(!MX([[1, 2], [3, 4], [5, 6]])->is_square, 'is_square returns falsey when matrix is not square');
ok(MX([[1, 2], [3, 4]])->is_square, 'is_square returns truthy when matrix is square');
ok(MX([])->is_square, 'is_square returns truthy when matrix is empty');

#Is Row Equivalent
ok(
  MX(
    [[1, 2, 3],
     [2, 1, 1],
     [4, 9, 4]]
   )->is_row_equivalent(
     MX(
       [[1, 2, 3],
        [2, 1, 1],
        [8, 18, 8]]
      )
    ),
  'is_row_equivalent returns true when matrices share row equivilence'
 );

ok(
  !MX(
    [[1, 2, 3],
     [2, 1, 1],
     [4, 9, 4]]
   )->is_row_equivalent(
     MX(
       [[1, 2, 3],
        [1, 2, 3],
        [1, 2, 3]]
      )
    ),
  'is_row_equivalent returns falsey when matrices do not share row equivilence'
 );

#Augmented
is_deeply(MX([[1, 2], [3, 4]])->augmented, MX([[1, 2, 0], [3, 4, 0]]), 'augmented adds a zero column to the end of the matrix');
is_deeply(MX([[1]])->augmented, MX([[1, 0]]), 'augmented adds a zero column to the end of the matrix');

#Concat Horizontal
is_deeply(
  MX([[1, 2], [3, 4]])->concat_horizontal(MX([[3, 4], [5, 6]])),
  MX([[1, 2, 3, 4], [3, 4, 5, 6]]),
  'concat_horizontal concatenates matrix rows horizontally'
 );
is_deeply(
  MX([[1, 2], [3, 4]])->concat_horizontal(MX([[3, 4], [5, 6], [7, 8]])),
  undef,
  'concat_horizontal returns undef matrices do not have the same height'
 );

#Is Invertible
ok(MX([[1, 2], [3, 4]])->is_invertible, 'is_invertible returns truthy when the matrix can be inverted');
ok(!MX([[1, 2], [2, 4]])->is_invertible, 'is_invertible return falsey when the matrix can be inverted');
ok(!MX([[1, 2], [3, 4], [5, 6]])->is_invertible, 'is_invertible return falsey when the matrix can be inverted');

#Inverse
is_deeply(MX([[1, 2], [3, 4]])->inverse, MX([[-2, 1], [1.5, -0.5]]), 'inverse returns the inverse matrix');
is_deeply(MX([[1, 0], [0, 1]])->inverse, MX([[1, 0], [0, 1]]), 'inverse returns the inverse matrix');
is_deeply(MX([[1, 10], [2, 20]])->inverse, undef, 'inverse returns undef when the matrix cannot be inverted');

#Determinant
is(
  MX([[1, 2, 3],
      [2, 1, 1],
      [4, 9, 4]])->determinant,
  29,
  'determinant returns the matrix determinant'
 );

is(
  MX([[1, 0],
      [0, 1]])->determinant,
  1,
  'determinant returns the matrix determinant'
 );
is(
  MX([[1, 0, 1],
      [0, 2, 1],
      [1, 1, 1]])->determinant,
  -1,
  'determinant returns the matrix determinant'
 );
is(
  MX([[3, 2, 3],
      [2, 23, 1],
      [4, 9, 4]])->determinant,
  19,
  'determinant returns the matrix determinant'
 );
is(
  MX([[3, 2, 3],
      [2, 23, 1],
      [9, 9, 4]])->determinant,
  -316,
  'determinant returns the matrix determinant'
 );

is(
  MX([[3, 2, 3],
      [2, 23, 1]])->determinant,
  undef,
  'determinant returns undef if the matrix has no determinant'
 );

#Is Linearly Independent
my $lin_ind_test1 = MX([[1, 1],
                        [4, 3],
                        [3, 4]])->is_linearly_independent;
my $lin_ind_test2 = MX([[1, 1, 1],
                        [4, 0, 1],
                        [8, 0, 2]])->is_linearly_independent;
my $lin_ind_test3 = MX([[1, 1, 1],
                        [4, 0, 1]])->is_linearly_independent;
my $lin_ind_test4 = MX([[1, 0],
                        [0, 1]])->is_linearly_independent;
my $lin_ind_test5 = MX([[4, 3],
                        [4, 3],
                        [4, 3]])->is_linearly_independent;

my $r = MatrixMath::Logic::Matrix->non_linear_independence_reasons;
is_deeply([@$lin_ind_test1], [1, undef], 'is_linearly_independent returns [1, undef] when matrix is linearly independent and gives no failure reason');
is_deeply([@$lin_ind_test4], [1, undef], 'is_linearly_independent returns [1, undef] when matrix is linearly independent and gives no failure reason');
is_deeply([@$lin_ind_test2], [undef, $r->{LINEAR_COMBINATION_DUPLICATE_VECTORS}], 'is_linearly_independent returns undef when matrix is not linearly indepenedent and returns the proper failure reason');
is_deeply([@$lin_ind_test3], [undef, $r->{R_MISMATCH}], 'is_linearly_independent returns [undef, matching_reason_code] when matrix is not linearly indepenedent');
is_deeply([@$lin_ind_test5], [undef, $r->{LINEAR_COMBINATION_DUPLICATE_VECTORS}], 'is_linearly_independent returns [undef, matching_reason_code] when matrix is not linearly indepenedent and returns the proper failure reason');

#Get Non Linear Independent Reason


done_testing();


