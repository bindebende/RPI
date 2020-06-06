#!/bin/bash

##### Vidware_Downloads: My script philosophy is to keep things clean and simple. That's why my first step is to create 3 different folders to keep the main elements of my script completely separate from each other. Before anything can be built, we first have to download 6 files in the form of "stable release tarballs". This is the raw source code my script will use to build the 6 programs. We also need 4 GPU-related files from the Raspberry Pi Foundation's official GitHub site that provide OpenGL ES and EGL support (they allow mpv to "talk" to the Raspberry's VideoCore GPU and thus facilitate hardware acceleration). All of this will go inside the "Vidware_Downloads" folder – which we're creating with the mkdir command:
mkdir Vidware_Downloads

##### Vidware_Build: This is the folder where all our "building" will take place – the folder where the raw source code of 6 programs will be compiled and transformed into working software. The "primary" program is FFmpeg. But my script also builds a mandatory library called libass – a subtitle renderer that mpv requires. It also builds an advanced H.264 video encoder (x264) and two advanced audio encoders (Fraunhofer AAC and LAME MP3):
mkdir Vidware_Build

##### Vidware_Packages: This folder will remain empty until the very end of the script. When the script is about 95% complete, all 6 programs will be fully built, installed, and "packaged". These packages are free-standing Debian installers (commonly known as .deb files). What makes these so incredibly useful is that at any time, you can use them to automatically install (or re-install) all the programs on another Raspberry or your existing Raspberry in the future – IN ONLY ONE MINUTE! No scripts or "building" required! My script will conveniently place all of them in the Vidware_Packages folder – so be sure to back them up to a safe place!
mkdir Vidware_Packages

##### I've discovered an odd quirk about checkinstall: If we don't manually create a standard usr doc path before running it, checkinstall will fail to install some of our programs. This affects the LAME MP3 encoder – but not having the path up to "doc" also affects FFmpeg (even if you don't build or install LAME). This command line takes care of that:
sudo mkdir -p /usr/share/doc/lame

##### You'll see a lot of "echo" commands in my script. Why? Because I like VISUAL SEPARATION. A simple echo command inserts a blank line in Terminal's output:
echo; echo

##### The echo command is also the tool I'm using to "print" information on the Terminal screen – such as letting the user know that we're about to download the tarballs. I also "pipe" the output of echo through the "fold" command with the "-s" option. This ensures my longer sentences are properly "word wrapped" and that my words aren't abruptly cut in half when they hit the edge of your Terminal screen:
echo "------------------------------"
echo "Now downloading the source code tarballs and other essential files for building FFmpeg, and the 3 advanced encoders. At a connection speed of 1 MB per second, it will take less than 20 seconds." | fold -s
echo "------------------------------"
echo

##### We're about to download all the files that the script needs. It may look like a lot, but the grand total is less than 18 MB! This is quite impressive when you consider that FFmpeg alone contains more than one MILLION lines of source code! Before we do the downloads, however, we need to change our current working directory to the Vidware_Downloads folder with the cd command:
cd /home/pi/Vidware_Downloads

##### This is where my script downloads the 11 files it needs. At the time of this writing – August 2018 – all URLs link to the most recent versions available. Be careful if you think you can simply update these links to get even more recent versions in the future! Other parts of my script make specific assumptions about these particular versions. So unless you fully understand all aspects of my script, you definitely don't want to do that!
wget -q --show-progress --no-use-server-timestamps https://ffmpeg.org/releases/ffmpeg-4.0.2.tar.bz2

wget -q --show-progress --no-use-server-timestamps https://github.com/libass/libass/releases/download/0.14.0/libass-0.14.0.tar.gz

wget -q --show-progress --no-use-server-timestamps https://download.videolan.org/x264/snapshots/x264-snapshot-20180831-2245-stable.tar.bz2

wget -q --show-progress --no-use-server-timestamps https://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.6.tar.gz

wget -q --show-progress --no-use-server-timestamps https://downloads.sourceforge.net/lame/lame-3.100.tar.gz

wget -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/libGLESv2.so

wget -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/libEGL.so

wget -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/pkgconfig/glesv2.pc

wget -q --show-progress --no-use-server-timestamps https://github.com/raspberrypi/firmware/raw/master/hardfp/opt/vc/lib/pkgconfig/egl.pc

##### For backup purposes – and for mental clarity – I deliberately decided not to "wget" the files directly into their ultimate destinations. Instead, I wanted all the downloads to first be consolidated into the Vidware_Downloads folder – and then copy them over, later on, into wherever they need to be. So that's what I'm doing here. Sudo is required, by the way, because the opt parent folder (and its children) are owned by user "root", not "pi". If we didn't add the "sudo", we would get a "permission denied" error:
sudo cp libGLESv2.so /opt/vc/lib

sudo cp libEGL.so /opt/vc/lib

sudo cp glesv2.pc /opt/vc/lib/pkgconfig

sudo cp egl.pc /opt/vc/lib/pkgconfig

##### This makes an exact copy of our 6 source code tarballs (for FFmpeg, mpv, etc.) and places them inside the Vidware_Build folder. Some of the tarballs end in tar.gz, while others end in tar.bz2 – hence the 2 separate lines:
cp *.gz /home/pi/Vidware_Build

cp *.bz2 /home/pi/Vidware_Build

##### We're pretty much all done with the Vidware_Downloads folder at this point – so we now need to make sure the script is performing its actions inside the Vidware_Build folder. That's why we cd into it. We then need to "unzip" the 6 source code tarballs into folders – that's what the 2 "ls" lines with the xargs command does (for technical reasons, you can't use a simple asterisk wildcard to unzip multiple tarballs in the same folder). Finally, I delete all the tarballs in the build folder with the rm command. Why? Because we already have the original copy of them in our Vidware_Downloads folder – so there's no reason to clutter things up with duplicate tarballs!
cd /home/pi/Vidware_Build

ls *.gz | xargs -n1 tar xzf

ls *.bz2 | xargs -n1 tar jxf

rm *.gz

rm *.bz2

##### I don't want to keep seeing "fdk-aac-0.1.6" as the source code folder name, for example. That's just confusing. Instead, I just want to see "aac" – because that's what it really is. It's the AAC audio encoder! That's why I'm simplifying all the source code folder names by renaming them with the mv command:
mv ffmpeg* ffmpeg

mv x264* x264

mv fdk* aac

mv lame* mp3

mv libass* libass

##### This is where we install the dependencies we need to build all 6 pieces of software – via "sudo apt-get install". Read my statement in the echo line for more detail:
echo; echo
echo "------------------------------"
echo "Now downloading and installing the dependencies – essential packages from the official Raspbian repository that are needed to build the programs. At a connection speed of 1 MB per second, it will take less than 50 seconds to download. It will then take about 5 minutes for your system to install all the packages." | fold -s
echo "------------------------------"
echo

sudo apt-get install -y automake checkinstall libsdl2-dev libva-dev libluajit-5.1-dev libgles2-mesa-dev libtool libvdpau-dev libxcb-shm0-dev texinfo libfontconfig1-dev libfribidi-dev python-docutils libbluray-dev libjpeg-dev libtheora-dev libvorbis-dev libgnutls28-dev linux-headers-rpi2 libomxil-bellagio-dev xdotool libcdio-cdda-dev libcdio-paranoia-dev libdvdread-dev libdvdnav-dev libbluray-dev

##### This begins the "software building" phase of my script. We're configuring and compiling the source code for our first program – the advanced x264 video encoder. That's what people mean by "building" a program. In the "./configure" line, we're enabling and disabling various options that will customize the build in the manner necessary for everything to work. We then compile the program with the "make -j4" command – which is quite impressive given that the "j4" means that all 4 cores inside the Raspberry's CPU will be computing simultaneously! For more information on how to use the encoders with FFmpeg, please see my extremely detailed appendices. After the x264 encoder is fully built, I use the checkinstall command to both install the program and "package it up" into the extremely useful .deb installer packages I mentioned earlier. The final line – sudo ldconfig – is essential in making sure the "shared libraries" are properly recognized.
echo; echo
echo "------------------------------"
echo "Now building the x264 video encoder. This will take about 2 to 3 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/x264

./configure --prefix=/usr --enable-shared --disable-opencl --extra-cflags="-march=armv8-a+crc -mfpu=neon-fp-armv8 -mtune=cortex-a53"

make -j4

sudo checkinstall -y --pkgname x264 --pkgversion 0.155 make install

sudo ldconfig

##### We now move on to build and install the Fraunhofer AAC audio encoder. I don't need to say much here because I already described the basic outline of the "building from source code" process in my above comments about the x264 encoder.
echo; echo; echo
echo "------------------------------"
echo "Now building the Fraunhofer AAC audio encoder. This will take about 3 to 4 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/aac

./autogen.sh

./configure --prefix=/usr --enable-shared

make -j4

sudo checkinstall -y --pkgname fdk-aac --pkgversion 0.1.6 make install

sudo ldconfig

##### Now we build and install the LAME MP3 audio encoder:
echo; echo; echo
echo "------------------------------"
echo "Now building the LAME MP3 audio encoder. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/mp3

./configure --prefix=/usr --enable-shared

make -j4

sudo checkinstall -y --pkgname mp3lame --pkgversion 3.100 make install

sudo ldconfig

##### Now we build and install the libass subtitle renderer (mpv will not work without this software library):
echo; echo; echo
echo "------------------------------"
echo "Now building the libass subtitle renderer. This will take about 1 minute." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/libass

./configure --prefix=/usr --enable-shared

make -j4

sudo checkinstall -y --pkgname libass --pkgversion 0.14.0 make install

sudo ldconfig

##### Now we build and install FFmpeg! This is the very powerful media "engine" at the center of everything we're doing. The last 3 "--enable" lines under "./configure" enable FFmpeg to access the 3 advanced encoders – x264, Fraunhofer AAC, and LAME MP3. Compiling a million+ lines of code is INTENSE and could easily overheat your CPU. Your Raspberry must therefore have its own small fan or an external fan blowing on it. Please see the explicit warnings on this subject in my instructions!
echo; echo; echo
echo "------------------------------"
echo "Now preparing to build FFmpeg. This will take about 2 minutes." | fold -s
echo "------------------------------"
echo

cd /home/pi/Vidware_Build/ffmpeg

./configure \
--prefix=/usr \
--enable-gpl \
--enable-nonfree \
--enable-static \
--enable-libtheora \
--enable-libvorbis \
--enable-omx \
--enable-omx-rpi \
--enable-mmal \
--enable-libxcb \
--enable-libfreetype \
--enable-libass \
--enable-gnutls \
--disable-opencl \
--enable-libcdio \
--enable-libbluray \
--extra-cflags="-march=armv8-a+crc -mfpu=neon-fp-armv8 -mtune=cortex-a53" \
--enable-libx264 \
--enable-libfdk-aac \
--enable-libmp3lame

echo; echo; echo
echo "------------------------------"
echo "Now building FFmpeg. This will take about 24 minutes on the Raspberry 3B+ (and 2 or 3 minutes longer on the 3B)." | fold -s
echo "------------------------------"
echo

make -j4

echo; echo; echo
echo "------------------------------"
echo "Now installing FFmpeg. This will take about 7 minutes." | fold -s
echo "------------------------------"
echo

sudo checkinstall -y --pkgname ffmpeg --pkgversion 4.0.2 make install

sudo ldconfig
