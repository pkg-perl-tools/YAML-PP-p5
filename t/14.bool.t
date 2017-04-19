#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Test::More;
use FindBin '$Bin';
use Data::Dumper;
use YAML::PP::Loader;

my $yaml = <<'EOM';
TRUE: true
FALSE: false
EOM

my $ypp_jp = YAML::PP::Loader->new(boolean => 'JSON::PP');
my $ypp_b = YAML::PP::Loader->new(boolean => 'boolean');
my $ypp_p = YAML::PP::Loader->new(boolean => 'perl');
my $data_jp = $ypp_jp->Load($yaml);
my $data_b = $ypp_b->Load($yaml);
my $data_p = $ypp_p->Load($yaml);

isa_ok($data_jp->{TRUE}, 'JSON::PP::Boolean');
is($data_jp->{TRUE}, 1, 'JSON::PP::Boolean true');
is(! $data_jp->{FALSE}, 1, 'JSON::PP::Boolean false');

isa_ok($data_b->{TRUE}, 'boolean');
is($data_b->{TRUE}, 1, 'boolean.pm true');
is(! $data_b->{FALSE}, 1, 'boolean.pm false');

cmp_ok(ref $data_p->{TRUE}, 'eq', '', "pure perl true");
cmp_ok($data_p->{TRUE}, '==', 1, "pure perl true");
cmp_ok($data_p->{FALSE}, '==', 0, "pure perl false");

done_testing;
