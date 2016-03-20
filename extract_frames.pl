#!/usr/bin/perl

use strict;
use warnings;

my $fps = "";

####################
## Introduction
###############
print "Extract Frames from Video\n";

##########################
## Conversion Process
#####################
# Extract Frames and Audio
my ($videoCommand,$audioCommand) = setupExtractCommand();
system($videoCommand); # extract frames
if($? == 0) {
    print "Extraction completed successfully!\n";
} else {
    print "There was a problem extracting frames.\nError code: $?\n";
}
system($audioCommand); # extract audio
if($? == 0) {
    print "Extraction completed successfully!\n";
} else {
    print "There was a problem extracting audio.\nError code: $?\n";
}
# Process Frames
my $waifuCommand = setupWaifuCommand();
system($waifuCommand);
if($? eq 0) {
    print "Success! Files have been waifu'd!\n";
} else {
    print "false";
    die "There was a problem waifuing the files.\nError code: $?";
}
# Export Video
my ($combineCommand) = setupExportCommand();
system($combineCommand);
if($? eq 0) {
    print "Extraction completed successfully!\n";
} else {
    print "There was a problem extracting frames.\nError code: $?\n";
}
##################################################################
# End of Process                                                 #
##################################################################

####################
## avconv setup
###############
sub setupExtractCommand {
    
    my $input = getInputFile();
    my $fps = getOutputFPS($input);
    my $outputLoc = getOutputLocation();
    my $audioCommand = "/usr/bin/avconv -i $input audio.mp3";
    my $videoCommand = "/usr/bin/avconv -i $input -r $fps -f image2 ".$outputLoc."frame-%08d.png";
    return ($videoCommand, $audioCommand);
}

####################
## getInputFile
###############
sub getInputFile {
    
    ###########################
    ## Asks user for input file
    print "\nEnter the full path to the video you would like to extract the frames from:\n> ";
    my $input = <STDIN>;
    chomp($input);
    if (-e $input) {
        return $input;
    } else {
        print "Sorry, that file cannot be found. Try again.\n";
        getInputFile();
    }
}

###################
## getOutputFPS
###############
sub getOutputFPS {

    my $file = shift;
    ###########################
    ## Asks user for output fps
    my $command = 'avprobe '.$file.' 2>&1 | grep -e \'Video\'';
    my $videoString = `$command`;
    my @fields = split(/ /, $videoString);
    for (my $i = 0; $i < scalar(@fields); $i++) {
        if (substr($fields[$i], 0, 3) eq "fps") {
            $fps = $fields[$i-1];
        }
    }
    print "The FPS has been determined to be: $fps\nIs this correct? (y/n)\n> ";
    my $response = <STDIN>;
    chomp($response);
    if ($response eq "y" or $response eq "Y") {
        return $fps;
    } elsif ($response eq "n" or $response eq "N") {
        print "\n\nSorry about that.\nHow many frames per second would you like to extract?\n> ";
        my $input = <STDIN>;
        chomp($input);
        return $input;
    } else {
        getOutputFPS();
    }
}

#########################
## getOutputLocation
####################
sub getOutputLocation {

    ################################
    ## Asks user for output location
    print "\nEnter the full path where you would like to save the frames:\n> ";
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
######################################################################


####################
## Process Frames ##
####################

###################
## waifu setup
##############
sub setupWaifuCommand {

    my $frameList = makeFrameList();
    my $outputDir = getOutputDirectory();

    my $process = "/usr/local/bin/th /media/waifu/waifu2x-master/waifu2x.lua ";
    $process .= "-model_dir /media/waifu/waifu2x-master/models/anime_style_art_rgb/ ";
    $process .= "-m noise_scale ";
    $process .= "-noise_level 1 ";
    $process .= "-resume 1 ";
    $process .= "-l $frameList ";
    $process .= "-o ".$outputDir."%08d.png";
    return $process;
}


####################
## makeFrameList
###############
sub makeFrameList {
    
    ###########################
    ## Asks user for input file
    my $frameDir = getFrameDirectory();
    my $findFrames = 'find '.$frameDir.' -name "*.png" | sort > /tmp/wave/frame.txt';
    system($findFrames);
    if($? eq 0) {
        print "Frame list has been created\n";
        $frameDir = "/tmp/wave/frame.txt";
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
    makeWaifuOutputDirectory($input);
    return $input;
}

###########################
## makeWaifuOutputDirectory
######################
sub makeWaifuOutputDirectory {
    my $filepath = shift;
    ########################
    ## Takes directory input
    ##  and creates it
    my $input = "mkdir -p ".$filepath;
    system($input);
    if($? eq 0) {
        return $filepath;
    } else {
        die "There was a problem creating $filepath.\nError code: $?";
    }
}
######################################################################


##################
## Export Video ##
##################

####################
## avconv Setup
###############
sub setupExportCommand {
    
    my $input = getExportInputFile();
    my $fps = getExportOutputFPS();
    my $outputFile = getExportOutputFile();
    my $combineCommand = "/usr/bin/avconv -f image2 -r $fps -i $input -i audio.mp3 -r $fps -vcodec libx264 -crf 16 -strict -2 $outputFile";
    return $combineCommand;
}

####################
## getInputFile
###############
sub getExportInputFile {
    my $framepath = "/tmp/wave/frames/";
    $framepath .= "frame-%08d.png";
    return $framepath;
}

####################
## getOutputFPS
###############
sub getExportOutputFPS {
    my $fps = "23.98";
    return $fps;
}

#####################
## getOutputFile
################
sub getExportOutputFile {
    my $output = "video.mp4";
    return $output;
}
