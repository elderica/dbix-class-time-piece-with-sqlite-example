use Mojo::Base -strict;

use Test::More;
use Time::Piece;

BEGIN {
    use_ok 'Schema';
}

use Schema;

my $dbname = 'data/test.sqlite3';

unlink $dbname;

system("sqlite3 $dbname < sql/schema.sql") == 0
    or die "Can't execute sqlite3";

my $schema = Schema->connect(
    "dbi:SQLite:dbname=$dbname",
    '',
    ''
);

my $history = $schema->resultset('History');

my $lt = localtime;
my $gmt = gmtime($lt->epoch);

my $inserted = $history->create({
    iso8601_datetime => $lt
});

my $resultset = $history->search({
    id => $inserted->id
});

my $row = $resultset->next;

subtest 'Time::Piece in, Time::Piece out' => sub {
    my $actual = $row->iso8601_datetime;

    is($actual->datetime, $lt->datetime);
};

subtest 'use UTC datetime in underlying SQLite database' => sub {
    my $actual = $row->get_column('iso8601_datetime');

    is($actual, $gmt->datetime);
};

done_testing;
