# LinuxCNC

This repository contains a script to install LinuxCNC on a
freshly installed Debian Buster system.

NOTE: This will install LinuxCNC in run-in-place mode.
If you don't want to compile your own version, you should
probably use a pre-built package from [buildbot] instead.

[buildbot]: http://buildbot.linuxcnc.org

## Install Debian

* Download the latest Debian Buster [CD image], and copy it to a USB stick:
  ```bash
  sudo dd status=progress if=debian-testing-amd64-netinst.iso of=/dev/sdX
  ```

[CD image]: https://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/debian-testing-amd64-netinst.iso

* Do a "Graphical install" on a partition with at least 20 GB space
  * Select `Xfce` and/or `Cinnamon` when asked for Software Selection.

* Add your new user to the `sudo` group:
  ```bash
  su --login
  adduser cnc sudo
  reboot
  ```

## Install LinuxCNC from Source

* Clone this repository

  ```bash
  sudo apt install -y git
  git clone https://github.com/thomask77/linuxcnc-tools
  ```

* Run `./install-from-git.sh`

  This will essentially do all the steps outlined in http://linuxcnc.org/docs/devel/html/code/building-linuxcnc.html


* If compiling fails with
  ```
  Syntax checking python script halcompile
  Traceback (most recent call last):
  File "<string>", line 1, in <module>
  File "objects/hal/utils/halcompile.py", line 26
      from __future__ import print_function
  SyntaxError: from __future__ imports must occur at the beginning of the file
  make: *** [hal/utils/Submakefile:89: ../bin/halcompile] Error 1
  make: *** Waiting for unfinished jobs....
  ```

  You have to comment out the **second**

  ```# from __future__ import print_function```

  (around line 26) in `halcompile.py`:

  ```bash
  nano linuxcnc/src/objects/hal/utils/halcompile.py
  ```

## Starting LinuxCNC

```bash
source linuxcnc/scripts/rip-environment
linuxcnc
```
