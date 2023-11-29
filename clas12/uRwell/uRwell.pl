#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use hit;
use bank;
use math;
use materials;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   uRwell.pl <configuration filename>\n";
 	print "   Will create the CLAS12 uRwell geometry, materials, bank and hit definitions\n";
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
#$configuration{"variation"} = "default" ;

# Global pars - these should be read by the load_parameters from file or DB


# materials
require "./materials.pl";

# banks definitions
require "./bank.pl";

# hits definitions
require "./hit.pl";

#system("which run-groovy");


# sensitive geometry
require "./geometry_java.pl";


# all the scripts must be run for every configuration
# Right now run both configurations, later on just ccdb
#my @allConfs = ("ccdb", "cosmicR1", "ddvcs", "java");
my @allConfs = ("default_1R", "default_2R", "proto");
my @allNregions =("1","2","1");
#my @allConfs = ($configuration{"variation"});

# bank definitions common to all variations
define_bank();

#foreach my $conf ( @allConfs ){
for(my $ii=0; $ii<=$#allConfs; $ii++){
#	$configuration{"variation"} = $conf ;
    $configuration{"variation"} = $allConfs[$ii];
    $configuration{"number_of_Region"} = $allNregions[$ii];
    print "$configuration{variation}\n";
    
    # run DC factory from COATJAVA to produce volumes
    system("../coatjava/bin/run-groovy factory.groovy --variation $configuration{variation} --runnumber 11 --number_of_Region $configuration{number_of_Region}");

  #  %configuration = $configuration{"variation"};
    
	# materials
	materials();

	# hits
	define_hit();
	

	# sensitive geometry
	# Global pars - these should be read by the load_parameters from file or DB
    our @volumes = get_volumes(%configuration);


    if ($configuration{"variation"} eq "proto"){
        print "variation proto\n";
        coatjava::makeURWELL_PROTO($configuration{"number_of_Region"});
    }
    elsif ($configuration{"variation"} ne "proto")
    {
        print "variation default\n";
        print "configuration{$configuration{variation})\n";
        coatjava::makeURWELL($configuration{"number_of_Region"});
    }
    
}

