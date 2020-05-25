# astr0shoot
Script that capture photos from your camera (connected to Raspberry) and sending them to your PC on the fly

### Setup

1. Get a Raspberry Pi 3 or 4 (so they have WIFI module embedded) and install Raspbian or whatever you like.
2. Connect it to the same WIFI network as your workstation PC. Make sure your router gives the same static IP always to Raspberry.
3. Install "gphoto2" to Raspberry
4. Connect your DSLR (tested with my Canon 550D) with USB to the Raspberry Pi

1. Setup passwordless SSH from your PC to Raspberry
2. Setup passwordless SSH from Raspberry to your PC

### Configure the script

Modify at least these variables:

```bash
remoteUser="astroberry"                 # Username of the Raspberry Pi user
REMOTEPC="astroberry"                   # IP Address or Hostname of the Raspberry Pi
localDir="/home/drpaneas/astroimages"   # Local directory to save the photos
```

### Run the script

> ./astr0shoot.sh $target $aperture $speed $iso $numberOfImages
