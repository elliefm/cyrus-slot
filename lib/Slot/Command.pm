package Slot::Command;

use strict;
use warnings;

use IPC::System::Simple qw(run);
use POSIX ();

use FindBin;
use lib "$FindBin::RealBin/../lib";

use Slot;

sub start {
    my ($command, $slot, $force) = @_;

    die "not initialised\n" if not -d Slot::slot_dir($slot);

    my $pidfile = Slot::slot_pidfile($slot);

    if (-e $pidfile) {
	my $pid = do {
	    local $/ = undef;
	    open my $fh, '<', $pidfile or die "$pidfile: $!";
	    <$fh>;
	};
	chomp $pid;

	die "pid file exists ($pid). already running?\n";
    }

    my $master = Slot::slot_binary($slot, 'master');

    if (0 == POSIX::getuid()) {
	# running as root, so actually start master

	run $master, '-d', '-p', $pidfile;

	print STDERR "slot $slot started\n";
    }
    else {
	# not running as root, just print sudo commands to stdout

	print "# run the following to start slot $slot\n";
	print "sudo $master -d -p $pidfile\n";
    }
}

1;
