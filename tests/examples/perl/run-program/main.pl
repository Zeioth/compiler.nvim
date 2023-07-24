#!/usr/bin/env perl
use strict;
use warnings;

# Add the current directory to @INC to include the helper.pl script
use lib '.';
require 'helper.pl';

# Call the hello_world subroutine from the helper script with a parameter
hello_world("Hello, World!");

