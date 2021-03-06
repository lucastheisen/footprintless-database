use strict;
use warnings;

package Footprintless::Plugin::Database::Command::db::backup;

# ABSTRACT: creates a backup of the database
# PODNAME: Footprintless::Plugin::Database::Command::db::backup

use parent qw(Footprintless::App::Action);

use Carp;
use Footprintless::App -ignore;
use Log::Any;

my $logger = Log::Any->get_logger();

sub execute {
    my ($self, $opts, $args) = @_;

    $logger->info('Performing backup...');
    eval {
        $self->{db}->connect();
        $self->{db}->backup($self->{file}, %{$self->{options}});
    };
    my $error = $@;
    $self->{db}->disconnect();
    die($error) if ($error);
    $logger->info('Done!');
}

sub opt_spec {
    return (
        ['file=s', 'the output file'],
        ['ignore-all-views', 'will ignore all views'],
        ['ignore-table=s@', 'will ignore the specified table'],
        ['only-table=s@', 'will only backup the specified table'],
        ['live', 'will backup live'],
    );
}

sub usage_desc {
    return 'fpl db DB_COORD backup %o';
}

sub validate_args {
    my ($self, $opts, $args) = @_;

    eval {
        $self->{db} = $self->{footprintless}->db($self->{coordinate});
    };
    croak("invalid coordinate [$self->{coordinate}]: $@") if ($@);

    $self->{file} = $opts->{file} || \*STDOUT;

    $self->{options} = {
        ignore_all_views => $opts->{ignore_all_views},
        ($opts->{ignore_table} ? (ignore_tables => $opts->{ignore_table}) : ()),
        live => $opts->{live},
        ($opts->{only_table} ? (only_tables => $opts->{only_table}) : ()),
    };
}

1;

__END__

=for Pod::Coverage execute opt_spec usage_desc validate_args
