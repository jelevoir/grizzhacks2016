#!/usr/bin/perl

use strict;
use warnings;

my $frameList = makeFrameList();
my $outputDir = getOutputDirectory();

#####################
## Waifu2x Setup
################
# th waifu2x.lua -m noise_scale -noise_level 1 -resume 1 -l list.txt -o images.png';
my $process = "/usr/local/bin/th /media/waifu/waifu2x-master/waifu2x.lua ";
$process .= "-model_dir /media/waifu/waifu2x-master/models/anime_style_art_rgb/ ";
$process .= "-m noise_scale ";
$process .= "-noise_level 1 ";
$process .= "-resume 1 ";
$process .= "-l $frameList ";
$process .= "-o ".$outputDir."%08d.png";
system($process);

if($? eq 0) {
    print "Success! Files have been waifu'd!\n";
} else {
    print "false";
    die "There was a problem waifuing the files.\nError code: $?";
}



####################
## makeFrameList
###############
sub makeFrameList {
    
    ###########################
    ## Asks user for input file
    my $frameDir = getFrameDirectory();
    my $findFrames = 'find '.$frameDir.'frames -name "*.png" | sort > frame.txt';
    system($findFrames);
    if($? eq 0) {
        print "Frame list has been created\n";
        $frameDir .= "frame.txt";
        return $frameDir;
    } else {
        die "Frame list could not be created.\nError code: $?";
    }
}

#########################
## getFrameDirectory
###############
sub getFrameDirectory {
    
    ################################
    ## Asks user for frame directory
    print "\nEnter the full path to where the frame folder is located:\n> ";
    my $dir = <STDIN>;
    chomp($dir);

    ###############################
    # Make sure the output location
    #  ends in a forward slash
    if (substr($dir, -1) ne "/") {
        $dir .= "/";
    }

    if (-d $dir) {
        return $dir;
    } else {
        print "Sorry, that folder cannot be found. Try again.\n";
        getFrameDirectory();
    }
}

#########################
## getOutputDirectory
####################
sub getOutputDirectory {

    ################################
    ## Asks user for output location
    print "\nEnter the full location where you would like to save the frames:\n> ";
    my $input = <STDIN>;
    chomp $input;

    ###############################
    # Make sure the output location
    #  ends in a forward slash
    if (substr($input, -1) ne "/") {
        $input .= "/";
    }
    makeOutputDirectory($input);
    return $input;
}

###########################
## makeOutputDirectory
######################
sub makeOutputDirectory {
    my $filepath = shift;
    ########################
    ## Takes directory input
    ##  and creates it
    my $input = "mkdir -p ".$filepath;
    system($input);
    if($? eq 0) {
        print "Directory created or exists!\n";
        return $filepath;
    } else {
        die "There was a problem creating $filepath.\nError code: $?";
    }
}
