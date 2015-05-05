package Slot;

use strict;
use warnings;

use Exporter;
use List::MoreUtils qw(uniq);

use vars qw(@EXPORT_OK);

@EXPORT_OK = qw(
    slot_basedir
    slot_defaults
    slot_dir
    slots
);

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

sub slots_from_fs {
    my $slot_basedir = slot_basedir;
    opendir my $dh, $slot_basedir or die "$slot_basedir: $!";

    my @slots = grep { -d "$slot_basedir/$_" and m/^\d+$/ } readdir $dh;

    closedir $dh;

    return sort @slots;
}

sub slots_from_string {
    my ($slot_str) = @_;

    return slots_from_fs if $slot_str eq '-a';

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
