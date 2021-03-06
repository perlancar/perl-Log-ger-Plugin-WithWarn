package Log::ger::Plugin::WithDie;

# DATE
# VERSION

use strict;
use warnings;

use Log::ger ();

sub get_hooks {
    my %conf = @_;

    return {
        create_routine_names => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $levels = \%Log::ger::Levels;

                return [{
                    log_subs    => [
                        (map { ["log_${_}_die", $_, "default"] }
                             grep {$levels->{$_} > 0 && $levels->{$_} <= 20} keys %$levels),
                    ],
                    is_subs     => [],
                    log_methods => [
                        (map { ["${_}_die", $_, "default"] }
                             grep {$levels->{$_} > 0 && $levels->{$_} <= 20} keys %$levels),
                    ],
                    logml_methods => [
                    ],
                    is_methods  => [
                    ],
                }, 0];
            }],
        before_install_routines => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                # wrap the logger
                for my $r (@{ $args{routines} }) {
                    my ($code, $name, $numlevel, $type) = @$r;
                    if ($type eq 'log_sub' && $name =~ /\Alog_\w+_die\z/) {
                        $r->[0] = sub {
                            $code->(@_);
                            die $args{formatters}{default}(@_)."\n";
                        };
                    } elsif ($type eq 'log_method' && $name =~ /\A\w+_die\z/) {
                        $r->[0] = sub {
                            $code->(@_);
                            shift;
                            die $args{formatters}{default}(@_)."\n";
                        };
                    }
                }
            },
        ],
    };
}

1;
# ABSTRACT: Add *_die logging routines

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Plugin 'WithDie';
 use Log::ger;
 my $log = Log::ger->get_logger;

These subroutines will also become available:

 log_error_die("blah!"); # in addition to log, will also die()
 log_fatal_die("blah!"); # in addition to log, will also die()

These logging methods will also become available:

 $log->error_die("blah!"); # in addition to log, will also die()
 $log->fatal_die("blah!"); # in addition to log, will also die()


=head1 DESCRIPTION


=head1 SEE ALSO

L<Log::ger::Plugin::WithWarn>

L<Log::ger::Plugin::WithCarp>

L<Log::ger::Plugin::Log4perl>
