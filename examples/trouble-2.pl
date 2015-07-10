use strict;
use warnings;
use blib;
use C::Blocks;
use C::Blocks::libperl;
use PDL;

die "You must give at least one input file\n" unless @ARGV;
my $filename = shift;

# Open the file
use PDL::IO::FlexRaw;
my $N_entries = (-s $filename) / length(pack('d', 0));
$N_entries = 1000;
my ($data_pdl) = mapflex($filename, [{
	Type => 'double', NDims => 1, Dims => [ $N_entries ],
}]);

# Here is a function that unpacks a piddle's dataref for me
clex {
	#define get_data_pointer_from_ref(dataref) (double *)(SvPVbyte_nolen(SvRV(dataref)))
}

BEGIN { print "line ", __LINE__, "\n" }

my $dt = 0.1;

# Construct the frequencies to query
my $N_frequencies = 1000;
my $power = zeros($N_frequencies);
my $frequencies = $power->xlogvals(1e-3, 100);

# Set up the data and compute the periodogram
my $data_ref = $data_pdl->get_dataref;
my $frequencies_ref = $frequencies->get_dataref;
my $power_ref = $power->get_dataref;
BEGIN { print "line ", __LINE__, "\n" }
cblock {
printf("line %d\n", __LINE__);
	/* Unpack the data */
	int N_data = SvIV($N_entries);
	int N_oms = SvIV($N_frequencies);
	double * data = get_data_pointer_from_ref($data_ref);
	double * oms = get_data_pointer_from_ref($frequencies_ref);
	double * power = get_data_pointer_from_ref($power_ref);
	double t_step = SvNV($dt);
	
printf("line %d\n", __LINE__);
	/* Compute the value for each frequency */
	int i, j;
	for (i = 0; i < N_oms; i++) {
printf("i = %d\n", i);
		double om = oms[i];
		
		/* compute tau */
		double sin_sum = double cos_sum = 0;
		for (j = 0; j < N_data; j++) {
			sin_sum += sin(2 * om * j * t_step);
			cos_sum += cos(2 * om * j * t_step);
		}
		double tau = atan(sin_sum / cos_sum) / 2 / om;
		
		/* compute the power at this frequency */
		sin_sum = cos_sum = 0;
		double cos_sq_sum = double sin_sq_sum = 0;
		double rel_t, sin_t, cos_t;
		for (j = 0; j < N_data; j++) {
			rel_t = j * t_step - tau
			sin_t = sin(om * rel_t);
			cos_t = cos(om * rel_t);
			sin_sum += data[j] * sin_t;
			cos_sum += data[j] * cos_t;
			sin_sq_sum += sin_t*sin_t;
			cos_sq_sum += cos_t*cos_t;
		}
		power[i] = (sin_sum*sin_sum / sin_sq_sum + cos_sum*cos_sum / cos_sq_sum) / 2;
printf("line %d\n", __LINE__);
	}
}
$power->upd_data;
BEGIN { print "line ", __LINE__, "\n" }

use PDL::Graphics::Prima::Simple;
line_plot($frequencies, $power);
