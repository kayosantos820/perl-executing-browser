#!/usr/bin/perl -w

# Copyright (c) 2005 Hans Jeuken. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

use strict;
use warnings;
use Term::ANSIColor;
use Syntax::Highlight::Engine::Kate;

# Input filename:
my $input_filename = $ARGV[0]; # input file is the first command line argument

my $line_to_underline;
if (defined $ARGV[1]) {
	$line_to_underline = $ARGV[1]; # line to underline is the second command line argument
} else {
	$line_to_underline = 0;
}

# Remove double slash '//' from script filenames (if any):
$input_filename =~ s/\/\//\//g;

# Detect script language by file extension:
my $language;
if ($input_filename =~ ".pl" or $input_filename =~ ".PL"){
	$language = "Perl";
}
if ($input_filename =~ ".pm" or $input_filename =~ ".PM"){
	$language = "Perl";
}
if ($input_filename =~ ".py" or $input_filename =~ ".PY"){
	$language = "Python";
}
if ($input_filename =~ ".php" or $input_filename =~ ".PHP"){
	$language = "PHP (HTML)";
}

# Open the input file read-only:
my $input_filehandle;
open ($input_filehandle, "<", "$input_filename");

# Read the file and push it into an array:
my @lines = <$input_filehandle>;
my $total_lines = scalar @lines;

# Close the input file:
close ($input_filehandle);

# Detect Perl and Python using the shebang line.
# Perl and Python scripts may not have a file extension.
my $first_line = $lines[0];
if ($first_line =~ m/\#\!.*perl/){
	$language = "Perl";
}
if ($first_line =~ m/\#\!.*python/){
	$language = "Python";
}

# Syntax::Highlight::Engine::Kate settings:
 my $highlighter = new Syntax::Highlight::Engine::Kate(
    language => $language,
    substitutions => {
       "<" => "&lt;",
       ">" => "&gt;",
       "&" => "&amp;",
       " " => "&nbsp;",
       "\t" => "&nbsp;&nbsp;&nbsp;",
       "\n" => "<BR>\n",
    },
    format_table => {
       Alert => ["<font color=\"#0000ff\">", "</font>"],
       BaseN => ["<font color=\"#007f00\">", "</font>"],
       BString => ["<font color=\"#c9a7ff\">", "</font>"],
       Char => ["<font color=\"#ff00ff\">", "</font>"],
       Comment => ["<font color=\"#7f7f7f\"><i>", "</i></font>"],
       DataType => ["<font color=\"#0000ff\">", "</font>"],
       DecVal => ["<font color=\"#00007f\">", "</font>"],
       Error => ["<font color=\"#ff0000\"><b><i>", "</i></b></font>"],
       Float => ["<font color=\"#00007f\">", "</font>"],
       Function => ["<font color=\"#007f00\">", "</font>"],
       IString => ["<font color=\"#ff0000\">", ""],
       Keyword => ["<b>", "</b>"],
       Normal => ["", ""],
       Operator => ["<font color=\"#ffa500\">", "</font>"],
       Others => ["<font color=\"#b03060\">", "</font>"],
       RegionMarker => ["<font color=\"#96b9ff\"><i>", "</i></font>"],
       Reserved => ["<font color=\"#9b30ff\"><b>", "</b></font>"],
       String => ["<font color=\"#ff0000\">", "</font>"],
       Variable => ["<font color=\"#0000ff\"><b>", "</b></font>"],
       Warning => ["<font color=\"#0000ff\"><b><i>", "</b></i></font>"],
    },
 );

# Highlight the syntax of the input file:
print "<html>\n";
print "<head>\n";
print "<title>$input_filename</title>\n";

# Output CSS styling:
print "<style type='text/css'>
			body {
				text-align: left;
				font-family: monospace;
				font-size: 14px;
				background-color: #FFFFFF;
				color: #000000;
				-webkit-user-select: none;
				}
			ol {
				list-style-type: decimal;
				background-color: #C0C0C0;
				padding-left: 6%;
				text-indent: 1.5%;
				border: green solid 3px;
				}
	</style>\n";

print "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>\n";
print "</head>\n";

print "<body>\n";

print "<p align='center' style='-webkit-user-select: auto;'><font size='3'>Syntax-highlighted source: $input_filename</font></p>\n";

print "<ol>\n";

my $line_number;
my $start_line;
my $end_line;

if ($line_to_underline == 0) {
	$start_line = 1;
	$end_line = $total_lines;
}

if ($total_lines <= 15 and $line_to_underline > 0) {
	$start_line = 1;
	$end_line = $total_lines;
}

if ($total_lines > 15 and $line_to_underline > 0) {
	$start_line = $line_to_underline - 15;
	$end_line = $line_to_underline + 15;
}

foreach my $line (@lines){
	$line_number++;

	if ($line_number >= $start_line and $line_number <= $end_line) {
		my $highlighted_line = $highlighter->highlightText ($line);

		if (length($line) > 2) {
			$highlighted_line =~ s/<BR>\n//g;
		}

		if ($line_number eq $line_to_underline) {
			print "<li style='background-color: #CCCCCC;' value='$line_number'><a name='$line_number'></a><div style='-webkit-user-select: auto;'>".$highlighted_line."</div>";
		} else {
			print "<li style='background-color: #FFFFFF;' value='$line_number'><a name='$line_number'></a><div style='-webkit-user-select: auto;'>".$highlighted_line."</div>";
		}

		print "</li>\n";
	}
}

print "</ol>\n";

print "</body>\n";

print "</html>\n";
