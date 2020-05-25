#!/bin/bash

###################################
#### CONFIGURATION - CHANGE IT ####
###################################
timeToWait=1                            # How much time (in seconds) to wait after sending the picture and before start taking a new one
remoteUser="astroberry"                 # Username of the Raspberry Pi user
REMOTEPC="astroberry"               	# IP Address of the Raspberry Pi
localDir="/home/drpaneas/astroimages"  	# Local directory to save the photos
colorspace="AdobeRGB"			# It doesn't matter if you are shooting RAW
ownerName="Panagiotis"
artist="drpaneas"
license="GPLv3.0"

######################################
#### DO NOT TOUCH THOSE VARIABLES ####
######################################
target=$1
aperture=$2
speed=$3
iso=$4
numberOfImages=$5

################################
##### CHECKS FOR ARGUMENTS #####
################################
if [ $# -eq 0 ]; then
        echo "No arguments provided"
        echo 'Example: ./astr0shoot.sh $target $aperture $speed $iso $numberOfImages'
        exit 1
fi

if [ "$target" == "" ]; then echo "target is not set"; exit 1; else
	if ! echo $target | grep '[[:alpha:]]' &> /dev/null; then
		echo "You cannot use a target name with only numbers"
		exit 1
	fi
fi

command="ssh $remoteUser@$REMOTEPC"

######################################
#### CHECKS FOR CAMERA CONNECTION ####
######################################
# Test if camers is On
if $command "gphoto2 --list-config &>/dev/null"; then
	echo
        echo "$($command gphoto2 --get-config=/main/other/d402 | grep "Current:" | awk -F 'Current: ' '{print $2}') is connected via USB"
        echo
else
        echo "Camera is not connected or it's turned off"
        echo "Please turn on/off the camera..."
        exit 1
fi

echo "Camera Info"
echo "-----------"

SN=$($command gphoto2 --get-config=/main/status/serialnumber | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Serial Number: $SN"
manufacturer=$($command gphoto2 --get-config=/main/status/manufacturer | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Manufacturer: $manufacturer"
model=$($command gphoto2 --get-config=/main/status/cameramodel | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Camera Model: $model"
modelNumber=$($command gphoto2 --get-config=/main/status/model | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Model Number: $modelNumber"
eosnumber=$($command gphoto2 --get-config=/main/status/eosserialnumber | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "EOS Serial: $eosnumber"
fw=$($command gphoto2 --get-config=/main/status/deviceversion | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Firmware: $fw"
battery=$($command gphoto2 --get-config=/main/status/batterylevel | grep "Current:" | awk -F 'Current: ' '{print $2}')
echo "Battery: $battery"


########################
#### Photo Metadata ####
########################
echo
echo "Metadata"
echo "--------"
$command gphoto2 --set-config=/main/settings/ownername="$ownerName"
$command gphoto2 --set-config=/main/settings/artist="$artist"
$command gphoto2 --set-config=/main/settings/copyright="$license"
echo "Owner=$($command gphoto2 --get-config=/main/settings/ownername | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Artist=$($command gphoto2 --get-config=/main/settings/artist | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Copyright=$($command gphoto2 --get-config=/main/settings/copyright | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Image Format=$($command gphoto2 --get-config=/main/imgsettings/imageformat | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo


##################################################
#### CHECK IF CAMERA SUPPORTS USER'S SETTINGS ####
##################################################
# Check aperture value
if ! $command gphoto2 --get-config /main/capturesettings/aperture | cut -d ' ' -f3 | grep ^$aperture\s*$ &> /dev/null; then
        echo "Failed! Wrong aperture value!"
        echo "Choose one of the following:"
        $command gphoto2 --get-config /main/capturesettings/aperture | cut -d ' ' -f3 | grep -v 'END' | awk NF
        exit 1
fi

# Check shutter speed value
if ! $command gphoto2 --get-config /main/capturesettings/shutterspeed | cut -d ' ' -f3 | grep ^$speed\s*$ &> /dev/null; then
        echo "Failed! Wrong shutter speed value!"
        echo "Choose one of the following:"
        $command gphoto2 --get-config /main/capturesettings/shutterspeed | cut -d ' ' -f3 | grep -v 'END' | grep -v 'Speed' | awk NF
        exit 1
fi

# Check ISO value
if ! $command gphoto2 --get-config /main/imgsettings/iso | cut -d ' ' -f3 | grep ^$iso\s*$ &> /dev/null; then
        echo "Failed! Wrong ISO value!"
        echo "Choose one of the following:"
        $command gphoto2 --get-config /main/imgsettings/iso | cut -d ' ' -f3 | grep -v 'END' | grep -v 'Speed' |  awk NF
        exit 1
fi

###############################
#### SET THE DESIRED STATE ####
###############################
echo "Set Desired Settings"
echo "--------------------"
if $command gphoto2 --set-config /main/capturesettings/aperture=$aperture; then
        echo "Aperture has been set at $aperture successfully"
else
        echo "Failed to set the aperture as user wanted."
        exit 1
fi

if $command gphoto2 --set-config /main/capturesettings/shutterspeed=$speed; then
        echo "Shutter speed has been set at $speed successfully"
else
        echo "Failed to set shutter speed as user wanted."
        exit 1
fi

if $command gphoto2 --set-config /main/imgsettings/iso=$iso; then
        echo "ISO has been set at $iso successfully"
else
        echo "Failed to set ISO as user wanted."
        exit 1
fi
echo

###############################
#### Current Configuration ####
###############################
echo "Current Configuration"
echo "---------------------"
echo "Focal Length: $($command gphoto2 --get-config=/main/status/lensname | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "White Balance: $($command gphoto2 --get-config=/main/imgsettings/whitebalance | grep "Current:" | awk -F 'Current: ' '{print $2}')"
$command gphoto2 --set-config=/main/imgsettings/colorspace=$colorspace
echo "Color Space: $($command gphoto2 --get-config=/main/imgsettings/colorspace | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Focus Mode: $($command gphoto2 --get-config=/main/capturesettings/focusmode | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Canon Auto Exposure Mode: $($command gphoto2 --get-config=/main/capturesettings/autoexposuremode | grep 'Current:' | awk -F 'Current: ' '{print $2}')"
echo "Drive Mode: $($command gphoto2 --get-config=/main/capturesettings/drivemode | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Picture Style: $($command gphoto2 --get-config=/main/capturesettings/picturestyle | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Metering Mode: $($command gphoto2 --get-config=/main/capturesettings/meteringmode | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Auto Exposure Bracketing: $($command gphoto2 --get-config=/main/capturesettings/aeb | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo "Auto Lighting Optimization: $($command gphoto2 --get-config=/main/capturesettings/alomode | grep "Current:" | awk -F 'Current: ' '{print $2}')"
echo

#########################################################
#### CHECK IF THE DESIRED STATE IS THE CURRENT STATE ####
#########################################################
echo "Check Current Settings"
echo "----------------------"
if $command gphoto2 --get-config /main/capturesettings/aperture | grep Current | awk -F ": " '{print $2}' | grep "$aperture" &> /dev/null; then
        echo "[OK] Aperture: f$($command gphoto2 --get-config /main/capturesettings/aperture | grep Current | awk -F ": " '{print $2}')"
else
        echo "Fail! User wanted $aperture but the current aperture value is f$($command gphoto2 --get-config /main/capturesettings/aperture | grep Current | awk -F ": " '{print $2}')"
        exit 1
fi
if $command gphoto2 --get-config /main/capturesettings/shutterspeed | grep "Current:" | awk -F ": " '{print $2}' | grep "$speed" &> /dev/null; then
        echo "[OK] Shutter Speed: $($command gphoto2 --get-config /main/capturesettings/shutterspeed | grep "Current:" | awk -F ": " '{print $2}') s"
else
        echo "Fail! User wanted $speed but the current shutter speed value is $($command gphoto2 --get-config /main/capturesettings/shutterspeed | grep "Current:" | awk -F ": " '{print $2}')"
        exit 1
fi
if $command gphoto2 --get-config /main/imgsettings/iso | grep "Current:" | awk -F ": " '{print $2}' | grep $iso &> /dev/null; then
        echo "[OK] ISO: $($command gphoto2 --get-config /main/imgsettings/iso | grep "Current:" | awk -F ": " '{print $2}')"
else
        echo "Fail! User wanted $iso but the current iso value is $($command gphoto2 --get-config /main/imgsettings/iso | grep "Current:" | awk -F ": " '{print $2}')"
        exit 1
fi

# Signal to the user that we are about to start showing logs for shooting
echo
echo "-------------------------------------------------------------"
echo

#########################
#### START CAPTURING ####
#########################
if [ -z $numberOfImages ]; then
        # When there is no value provided by the user
        echo "Number of images not provided. I will shoot only 1 photo"
        echo
        numberOfImages=1
else
        # When there is a value provided by the user
        echo "I will shoot $numberOfImages photos"
        echo
fi

for ((image=1 ; image<=${numberOfImages}; image++)); do
        echo "--- Start taking picture $image/$numberOfImages ---"
        echo

        echo "Shooting $image/$numberOfImages"
        echo "------------"
        if $command gphoto2 --capture-image-and-download --no-keep; then
                echo "Picture has been taken and downloaded to the PC sucessfully."
        else
                echo "Failed to take and download the picture"
                exit 1
        fi

        echo

        echo "File Handling $image/$numberOfImages"
        echo "-----------------"
	# Extract the suffix
	lastImage=$($command "ls -rt | tail -n 1 | xargs file --mime-type | grep ': image/' | cut -d ':' -f 1")
	filename=$(basename -- "$lastImage")
	extension="${filename##*.}"
	file="$target-f$aperture-exp$speed-iso$iso-image$image-$(date +"%d_%m_%Y_%T").$extension"
	echo "file is $file"
	# replace '/' with '_' otherwise OS thinks this is a another directory '/'.
	echo "Filanemae is: $filename"
	filename=$(echo "$file" | tr /: _)

	echo "Last image is: $lastImage"
	echo "Filanemae is: $filename"
        if $command mv "$lastImage" "$filename"; then
                echo "$lastImage has been renamed into $filename"
        else
                echo "Failed to rename $lastImage image"
                exit 1
        fi

        if scp $remoteUser@$REMOTEPC:$filename $localDir; then
                echo "Image has been sent to Panos Linux PC"
        else
                echo "Failed to send the image to Panos Linux PC"
                exit 1
        fi

        if $command rm $filename; then
                echo "$filename has been deleted from Astroberry"
        else
                echo "Failed to delete the image $filename from Astroberry"
                exit 1
        fi

        echo
        echo "Wait for $timeToWait second ... ... ..."
        sleep $timeToWait
        echo

done

