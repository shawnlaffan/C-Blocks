# This tests the libperl interface to make sure that we can communicate between
# the perl interpreter and the cblocks. This requires a faily substantial
# amount of the C::Blocks machinery to be functional, so it is perhaps not the
# best thing to rely on for so much of the testing. But then again, if it works
# we know that quite a bit of C::Blocks works, too.

use strict;
use warnings;
use Test::More;

# Load cblocks and libperl
use C::Blocks;
cuse C::Blocks::libperl;

# Work with package globals for now
our $shuttle;

cblock {
	SV * shuttle = Perl_get_sv(my_perl, "shuttle", 0);
	Perl_sv_setiv(my_perl, shuttle, 5);
}

is($shuttle, 5, 'Can set Perl data in a cblock using direct function calls');

cblock {
	SV * shuttle = get_sv("shuttle", 0);
	sv_setiv(shuttle, -5);
}

is($shuttle, -5, 'Can set Perl data using macros');

cblock {
	SV * shuttle = get_sv("shuttle", 0);
	sv_setiv(shuttle, 10);
}

is($shuttle, 10, 'Repeated cblocks work correctly');

done_testing;
