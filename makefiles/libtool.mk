ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += libtool
LIBTOOL_VERSION := 2.5.0
DEB_LIBTOOL_V   ?= $(LIBTOOL_VERSION)

libtool-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://git.savannah.gnu.org/cgit/libtool.git/snapshot/libtool-$(LIBTOOL_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,libtool-$(LIBTOOL_VERSION).tar.gz)
	$(call EXTRACT_TAR,libtool-$(LIBTOOL_VERSION).tar.gz,libtool-$(LIBTOOL_VERSION),libtool)

ifneq ($(wildcard $(BUILD_WORK)/libtool/.build_complete),)
libtool:
	@echo "Using previously built libtool."
else
libtool: libtool-setup
	cd $(BUILD_WORK)/libtool && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--program-prefix=g \
		--enable-ltdl-install \
		SED="sed" \
		GREP="grep" \
		EGREP="grep -E" \
		FGREP="grep -F"
	+$(MAKE) -C $(BUILD_WORK)/libtool
	+$(MAKE) -C $(BUILD_WORK)/libtool install \
		DESTDIR=$(BUILD_STAGE)/libtool
	$(call AFTER_BUILD,copy)
endif
libtool-package: libtool-stage
	# libtool.mk Package Structure
	rm -rf $(BUILD_DIST)/libtool{,-bin} $(BUILD_DIST)/libltdl{7,-dev}
	mkdir -p $(BUILD_DIST)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/{man/man1,libtool,aclocal}} \
		$(BUILD_DIST)/libtool-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share/man/man1} \
		$(BUILD_DIST)/libltdl7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libltdl-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib,share/{libtool,aclocal}}

	# libtool.mk Prep libtool
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/glibtoolize $(BUILD_DIST)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/glibtoolize.1$(MEMO_MANPAGE_SUFFIX) $(BUILD_DIST)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/aclocal/!(ltdl.m4) $(BUILD_DIST)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/aclocal
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/libtool/build-aux $(BUILD_DIST)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/libtool

	# libtool.mk Prep libtool-bin
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/glibtool $(BUILD_DIST)/libtool-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1/glibtool.1$(MEMO_MANPAGE_SUFFIX) $(BUILD_DIST)/libtool-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1

	# libtool.mk Prep libltdl7
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libltdl.7.dylib $(BUILD_DIST)/libltdl7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libtool.mk Prep libltdl-dev
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libltdl.7.dylib) $(BUILD_DIST)/libltdl-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/aclocal/ltdl.m4 $(BUILD_DIST)/libltdl-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/aclocal
	cp -a $(BUILD_STAGE)/libtool/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/libtool/!(build-aux) $(BUILD_DIST)/libltdl-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/libtool

	# libtool.mk Sign
	$(call SIGN,libtool,general.xml)
	$(call SIGN,libtool-bin,general.xml)
	$(call SIGN,libltdl7,general.xml)

	# libtool.mk Make .debs
	$(call PACK,libtool,DEB_LIBTOOL_V)
	$(call PACK,libtool-bin,DEB_LIBTOOL_V)
	$(call PACK,libltdl7,DEB_LIBTOOL_V)
	$(call PACK,libltdl-dev,DEB_LIBTOOL_V)

	# libtool.mk Build cleanup
	rm -rf $(BUILD_DIST)/libtool{,-bin} $(BUILD_DIST)/libltdl{7,-dev}

.PHONY: libtool libtool-package
