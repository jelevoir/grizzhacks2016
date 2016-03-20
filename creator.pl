#!/usr/bin/perl

use strict;
use warnings;

my ($combineCommand) = setupCommand();
system($combineCommand);

if($? eq 0) {
    print "Extraction completed successfully!\n";
} else {
    print "There was a problem extracting frames.\nError code: $?\n";
}

####################
## avconv Setup
###############
sub setupCommand {
    
    my $input = getInputFile();
    my $fps = getOutputFPS();
    my $outputFile = getOutputFile();
    my $combineCommand = "/usr/bin/avconv -f image2 -r $fps -i $input -i audio.mp3 -r $fps -vcodec libx264 -crf 16 -strict -2 $outputFile";
    return $combineCommand;
}

####################
## getInputFile
###############
sub getInputFile {
    my $framepath = "frames/";
    $framepath .= "frame-%08d.png";
    return $framepath;
}

####################
## getOutputFPS
###############
sub getOutputFPS {
    my $fps = "23.98";
    return $fps;
}

#####################
## getOutputFile
################
sub getOutputFile {
    my $output = "video.mp4";
    return $output;
}
