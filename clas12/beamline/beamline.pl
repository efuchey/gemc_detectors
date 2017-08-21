#!/usr/bin/perl -w


use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use math;
use materials;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   beamline.pl <configuration filename>\n";
 	print "   Will create the CLAS12 beamline and materials\n";
 	print "   Note: The passport and .visa files must be present if connecting to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file and paramters
our %configuration = load_configuration($ARGV[0]);


# Global pars - these should be read by the load_parameters from file or DB

# General:
our $inches = 25.4;


# vacuum line throughout the shields, torus and downstream
require "./vacuumLineNew.pl";

# air beampipe between the target and the vacuum line
require "./gapLine.pl";

my @allConfs = ("FTOn", "FTOff", "FTOn2");

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;

	# vacuum line throughout the shields, torus and downstream
	# temp includes the torus back nose
	vacuumLine();

	# air pipe between target and shield
    gapLine();
}



