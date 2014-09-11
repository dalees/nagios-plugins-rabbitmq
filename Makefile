
# Copyright (c) 2014 Catalyst IT http://www.catalyst.net.nz
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Authors:
#     Dale Smith <dale@catalyst-eu.net>
#
# Based on nagios-plugins-ceph Makefile by:
#     Valery Tschopp <valery.tschopp@switch.ch>
#     Ricardo Rocha <ricardo@catalyst.net.nz>

name = nagios-plugins-rabbitmq
version = 1.1.0ppa1

# install options (like configure)
# ex: make sysconfdir=/etc libdir=/usr/lib64 sysconfdir=/etc install
prefix = /usr
libdir = $(prefix)/lib
sysconfdir = $(prefix)/etc
nagiosdir = $(libdir)/nagios/plugins
nagiosconfdir = $(sysconfdir)/nagios-plugins/config
nrpeconfdir = $(sysconfdir)/nagios/nrpe.d

tmp_dir = $(CURDIR)/tmp

.PHONY: clean dist install deb

clean:
	rm -rf $(tmp_dir) $(name)*.tar.gz $(name)*.deb

dist:
	@echo "Packaging sources"
	test ! -d $(tmp_dir) || rm -rf $(tmp_dir)
	mkdir -p $(tmp_dir)/$(name)-$(version)
	cp Makefile $(tmp_dir)/$(name)-$(version)
	cp LICENSE.txt README.md $(tmp_dir)/$(name)-$(version)
	cp -R scripts $(tmp_dir)/$(name)-$(version)
	cp -R etc $(tmp_dir)/$(name)-$(version)
	cp -R debian $(tmp_dir)/$(name)-$(version)
	rm -f $(name)-$(version).tar.gz
	tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz $(name)-$(version)
	@echo "$(name)-$(version).tar.gz created."
	rm -fr $(tmp_dir)

install:
	@echo "Installing RabbitMQ Nagios plugins in $(DESTDIR)$(nagiosdir)"
	install -d $(DESTDIR)$(nagiosdir)
	install -m 0755 scripts/* $(DESTDIR)$(nagiosdir)
	@echo "Installing RabbitMQ nrpe configs in $(DESTDIR)$(nrpeconfdir)"
	install -d $(DESTDIR)$(nrpeconfdir)
	install -m 0644 etc/nagios/nrpe.d/* $(DESTDIR)$(nrpeconfdir)
	# Note: we are purposefully ignoring files in etc/nagios-plugins/config as these are for Nagios/Icinga, not this NRPE package.

deb: dist
	@echo "Debian packaging..."
	mkdir -p $(tmp_dir)
	cp $(name)-$(version).tar.gz $(tmp_dir)/$(name)_$(version).orig.tar.gz
	tar -C $(tmp_dir) -xzf $(tmp_dir)/$(name)_$(version).orig.tar.gz
	cd $(tmp_dir)/$(name)-$(version); debuild -uc -us
	cp $(tmp_dir)/$(name)*.deb .
	rm -rf $(tmp_dir)

ppa: dist
	@echo "Building source PPA and signing..."
	mkdir -p $(tmp_dir)
	cp $(name)-$(version).tar.gz $(tmp_dir)/$(name)_$(version).orig.tar.gz
	tar -C $(tmp_dir) -xzf $(tmp_dir)/$(name)_$(version).orig.tar.gz
	cd $(tmp_dir)/$(name)-$(version); debuild -S
	@echo
	@echo "---"
	@echo "To upload the PPA, run the following command:"
	@echo "dput ppa:<ppa target> <changes file>"
	@echo "eg."
	@echo "dput ppa:dalees/openstack tmp/$(name)_$(version)_source.changes"
	@echo "---"
