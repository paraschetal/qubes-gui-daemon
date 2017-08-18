#
# The Qubes OS Project, http://www.qubes-os.org
#
# Copyright (C) 2010  Joanna Rutkowska <joanna@invisiblethingslab.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#

RPMS_DIR=rpm/
VERSION := $(shell cat version)

DIST_DOM0 ?= fc13

help:
	@echo "Qubes GUI main Makefile:" ;\
	    echo "make rpms                 <--- make all rpms and sign them";\
	    echo "make rpms-dom0            <--- create binary rpms for dom0"; \
	    echo "make rpms-vm              <--- create binary rpms for appvm"; \
	    echo; \
	    echo "make clean                <--- clean all the binary files";\
	    echo "make update-repo-current  <-- copy newly generated rpms to qubes yum repo";\
	    echo "make update-repo-current-testing <-- same, but for -current-testing repo";\
	    echo "make update-repo-unstable <-- same, but to -testing repo";\
	    echo "make update-repo-installer -- copy dom0 rpms to installer repo"
	    @exit 0;

dom0: gui-daemon/qubes-guid shmoverride/shmoverride.so shmoverride/X-wrapper-qubes \
		pulse/pacat-simple-vchan screen-layout-handler/watch-screen-layout-changes

gui-daemon/qubes-guid:
	(cd gui-daemon; scan-build $(MAKE))

shmoverride/shmoverride.so:
	(cd shmoverride; scan-build $(MAKE) shmoverride.so)

shmoverride/X-wrapper-qubes:
	(cd shmoverride; scan-build $(MAKE) X-wrapper-qubes)
	
pulse/pacat-simple-vchan:
	scan-build $(MAKE) -C pulse pacat-simple-vchan

screen-layout-handler/watch-screen-layout-changes:
	scan-build $(MAKE) -C screen-layout-handler watch-screen-layout-changes

rpms: rpms-dom0 rpms-vm
	rpm --addsign rpm/x86_64/*$(VERSION)*.rpm
	(if [ -d rpm/i686 ] ; then rpm --addsign rpm/i686/*$(VERSION)*.rpm; fi)

rpms-vm:
	rpmbuild --define "_rpmdir rpm/" -bb rpm_spec/gui-vm.spec

rpms-dom0:
	rpmbuild --define "_rpmdir rpm/" -bb rpm_spec/gui-dom0.spec

tar:
	git archive --format=tar --prefix=qubes-gui/ HEAD -o qubes-gui.tar

clean:
	(cd common; $(MAKE) clean)
	(cd gui-common; $(MAKE) clean)
	(cd gui-daemon; $(MAKE) clean)
	(cd shmoverride; $(MAKE) clean)
	$(MAKE) -C pulse clean

