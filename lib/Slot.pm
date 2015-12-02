package Slot;
use base qw(Exporter);

use strict;
use warnings;

use List::MoreUtils qw(uniq);

our @EXPORT_OK = qw(
    slot_dir
    slot_pidfile
    slot_binary
    slots
    slots_from_string
);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub slot_basedir {
    # FIXME don't hardcode this
    return '/cyrus/slot';
}

sub slot_defaults {
    # FIXME don't hardcode this
    return slot_basedir . '/defaults';
}

sub slot_dir {
    my ($slot) = @_;

    # FIXME check if valid slot

    return slot_basedir . '/' . $slot;
}

sub slot_pidfile {
    my ($slot) = @_;

    return slot_dir($slot) . "/var/run/cyrus-master.pid";
}

sub slot_binary {
    my ($slot, $name) = @_;

    foreach (qw( bin sbin libexec libexec/cyrus-imapd lib cyrus/bin )) {
        my $dir = slot_dir($slot) . "/usr/cyrus/$_";

        if (opendir my $dh, $dir) {
            if (grep { $_ eq $name } readdir $dh) {
                closedir $dh;
                return "$dir/$name";
            }

            closedir $dh;
        }
    }

    die "couldn't find binary: $name\n";
}

sub slots {
    my $slot_basedir = slot_basedir;
    opendir my $dh, $slot_basedir or die "$slot_basedir: $!";

    my @slots = grep { -d "$slot_basedir/$_" and m/^\d+$/ } readdir $dh;

    closedir $dh;

    return sort @slots;
}

sub slots_from_string {
    my ($slot_str) = @_;

    return if $slot_str !~ m/^[\d,-]+$/;

    my @ranges = split /\,/, $slot_str;
    return if not scalar @ranges;

    my @slots;

    foreach my $range (@ranges) {
        my ($start, $end, $junk) = split /-/, $range;

        if (defined $junk) {
            print STDERR "invalid range: $range\n";
            return;
        }
        elsif (not $start) {
            print STDERR "invalid range: $range\n";
            return;
        }
        elsif (not $end) {
            push @slots, $start;
        }
        else {
            if ($start < $end) {
                push @slots, $start .. $end;
            }
            else {
                print STDERR "invalid range: $range\n";
                return;
            }
        }
    }

    return sort { $a <=> $b } uniq @slots;
}

1;
