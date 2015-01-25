#!/usr/bin/perl -w

if ( @ARGV <= 0 ) {
	print "\n\t Usage:  $0 WHATEVER::Module::Name\n\n";
	exit(127);
}

sub try_load {
  my $mod = shift;

  eval("use $mod");

  if ($@) {
    return(0);
  } else {
    return(1);
  }
}

$module = $ARGV[0];

if (try_load($module)) {
  print "Module " . $module . " installed.\n";
  exit (0);
} else {
  print "Couldn't find Module " . $module . "!\n";
  exit (1);
}

exit (127);
