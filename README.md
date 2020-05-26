# astr0shoot
Script that capture photos from your camera (connected to Raspberry) and sending them to your PC on the fly

### Setup

1. Get a Raspberry Pi 3 or 4 (so they have WIFI module embedded) and install Raspbian or whatever you like.
2. Connect it to the same WIFI network as your workstation PC. Make sure your router gives the same static IP always to Raspberry.
3. Install "gphoto2" to Raspberry
4. Install and start openssh server and turn off the firewall if there is anything blocking TCP 22
4. Connect your DSLR (tested with my Canon 550D) with USB to the Raspberry Pi

### Password-less SSH

#### From Windows 10 to RPi

Install whatever Linux WSL you like. The following example is with openSUSE Leap 15.1:

* Fix the systemctl issue

```bash
sudo mv /usr/bin/systemctl /usr/bin/systemctl.old
sudo curl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py > /usr/bin/systemctl
sudo chmod +x /usr/bin/systemctl
sudo systemctl start sshd
```

* Make sure you have port 22 TCP open in your Windows box.

```
Control Panel > System and Security > Windows Firewall > Advanced Settings > Inbound Rules
```

Over there, add a new rule for port 22.

Now

* Create a key

```bash
$ ssh-keygen # press enter to all the questions
```

* Copy the key to Raspberry

```
ssh-copy-id $rpi-user@rpi-ip
```

* Now connect to your RPi without typing the password

```
ssh $rpi-user@rpi-ip
```
You must be connected to RPi by now.

* Send the key from RPi to Windows Linux WSL

```
ssh-copy-id $rpi-user@rpi-ip
```

* Connect back from RPi to Windows without typing the password

```
ssh $linux-wsl-username@windows-box-ip
```

### Configure the script

Create a folder first to store the images in your WSL:

```
$ mkdir /mnt/c/astroimages
```

This folder should be accessible by `C:\astroimages` outside of the WSL.

Now open the script and modify at least these variables:

```bash
remoteUser="astroberry"                 # Username of the Raspberry Pi user
REMOTEPC="192.168.178.68"               # IP Address or Hostname of the Raspberry Pi
localDir="/mnt/c/astroimages"           # Local directory to save the photos
```

### Run the script

> ./astr0shoot.sh $target $aperture $speed $iso $numberOfImages
