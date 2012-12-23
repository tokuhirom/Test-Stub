#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use Test::More tests => 1;

use lib grep { -d } qw(../lib ./lib);
use Test::Stub qw(stub);

{
  package One;
  use strict;
  use warnings;

  sub new { bless \(shift) }

  sub one { 'one' }
  sub yi1 { '一' }
  sub uno { 'uno' }
}

my $one = One->new;
stub($one)->one('two');
stub($one)->yi1('二');
stub($one)->uno('dos');

is_deeply(
  [map { $one->$_ } qw(one yi1 uno)],
  ['two', '二', 'dos'],
  'stubbing stacked correctly'
);
