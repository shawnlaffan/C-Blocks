package Alien::TinyCC;

use strict;
use warnings;

# EDIT THIS LINE with your prefix:
my $dist_dir = ...;

# Make sure that later require and use statements don't choke
$INC{'Alien/TinyCC.pm'} = $INC{'inc/Alien/TinyCC.pm'};

# Make sure we have LD_LIBRARY_PATH available. It seems that setting it
# below doesn't actually work! :-(
my $calling_filename = (caller)[1];
if($calling_filename ne 'Build.PL'
	and (!$ENV{LD_LIBRARY_PATH} or index($ENV{LD_LIBRARY_PATH}, libtcc_library_path()) == -1))
{
	die '***  Be sure to execute your programs like so:
***  LD_LIBRARY_PATH="' . $dist_dir . "/lib\" perl -Mblib -Mlib=inc $0 @ARGV\n";
}

############################
# Path retrieval functions #
############################

use Env qw( @PATH );
# Find the path to the tcc executable
sub path_to_tcc {
	return $dist_dir if $^O =~ /MSWin/;
	return File::Spec->catdir($dist_dir, 'bin');
}

# Modify the PATH environment variable to include tcc's directory
unshift @PATH, path_to_tcc();

# Find the path to the compiled libraries. Note that this is only applicable
# on Unixish systems; Windows simply uses the %PATH%, which was already
# appropriately set.
sub libtcc_library_path {
	return $dist_dir if $^O =~ /MSWin/;
	return File::Spec->catdir($dist_dir, 'lib');
}

# Add library path on Unixish:
if ($ENV{LD_LIBRARY_PATH}) {
	$ENV{LD_LIBRARY_PATH} = libtcc_library_path() . ':' . $ENV{LD_LIBRARY_PATH};
}
elsif ($^O !~ /MSWin/) {
	$ENV{LD_LIBRARY_PATH} = libtcc_library_path();
}

# Determine path for libtcc.h
sub libtcc_include_path {
	return File::Spec->catdir($dist_dir, 'libtcc') if $^O =~ /MSWin/;
	return File::Spec->catdir($dist_dir, 'include');
}

###########################
# Module::Build Functions #
###########################

sub MB_linker_flags {
	return ('-L' . libtcc_library_path, '-ltcc');
}

# version

1;

__END__

=head1 NAME

inc::Alien::TinyCC - stand-in for Alien::TinyCC for development

=head1 SYNOPSIS

 # Edit inc::Alien::TinyCC and set:
 my $dist_dir = 'path/to/your/current/tcc/prefix';
 ...

=head1 DESCRIPTION

The purpose of this module is to make it easy for you to work on tcc development
and easily test the resulting work on C::Blocks. You would do this by running
the C<configure> script in your tcc source directory with the C<--prefix>
switch set to whatever path you like. Then, edit 

=cut