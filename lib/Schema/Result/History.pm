package Schema::Result::History;

use Mojo::Base 'DBIx::Class::Core';

use Time::Piece;

__PACKAGE__->table('history');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_nullable => 0,
    },
    iso8601_datetime => {
        data_type => 'datetime',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->inflate_column('iso8601_datetime', {
    inflate => sub {
        my $iso8601_string = shift;
        my $gmt = Time::Piece->strptime($iso8601_string, '%Y-%m-%dT%H:%M:%S');
        localtime($gmt->epoch);
    },
    deflate => sub {
        my $localtime = shift;
        my $gmt = gmtime($localtime->epoch);
        $gmt->datetime;
    }
});
1;
