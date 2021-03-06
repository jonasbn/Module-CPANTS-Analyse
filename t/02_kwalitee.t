use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::NoWarnings;
use Env qw($TEST_VERBOSE);

use Module::CPANTS::Kwalitee;

my $CORE = 16;
my $EXTRA = 8; #is_extra set
my $EXPERIMENTAL = 3; #experimental?
my $METRICS = $CORE + $EXTRA + $EXPERIMENTAL;

# first 4 tests + all metrics + groups + 5 kwalitee indicators
plan tests => 4 + 2 * $METRICS + 5;

my $k=Module::CPANTS::Kwalitee->new({});

# 2 tests
is($k->available_kwalitee, $CORE, 'available kwalitee');
is($k->total_kwalitee, $CORE + $EXTRA, 'total kwalitee');

# 2 tests
my $ind=$k->get_indicators_hash;
is(ref($ind),'HASH','indicator_hash');
is(ref($ind->{use_strict}),'HASH','hash element');

{
    my @all=$k->all_indicator_names;
    is(@all, $METRICS, 'number of all indicators');
}

{
    my @all=$k->core_indicator_names;
    is(@all, $CORE, 'number of core indicators');
}

{
    my @all=$k->optional_indicator_names;
    is(@all, $EXTRA,'number of optional indicators');
}

{
    my @all=$k->experimental_indicator_names;
    is(@all, $EXPERIMENTAL,'number of experimental indicators');
}

# 5 tests
foreach my $mod (@{$k->generators}) {
    #$mod->analyse($me);
    if ($TEST_VERBOSE) {
        diag("examining generator: $mod");
    }
    foreach my $i (@{$mod->kwalitee_indicators}) {
        like $i->{name}, qr/^\w{3,}$/, $i->{name};
        # to check if someone has put a $var in single quotes by mistake...
        unlike $i->{error}, qr/\$[a-z]/, "error of $i->{name} has no \$ sign";

        if ($TEST_VERBOSE) {
            diag("examining kwalitee indicator: ", $i->{name});
        }

        # next if $i->{needs_db};
        # print $i->{name}."\n" if $me->opts->{verbose};
        # my $rv=$i->{code}($me->d, $i);
        # $me->d->{kwalitee}{$i->{name}}=$rv;
        # $kwalitee+=$rv;
    }
}
