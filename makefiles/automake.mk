ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS       += automake
AUTOMAKE_VERSION  := 1.17
DEB_AUTOMAKE_V    ?= $(AUTOMAKE_VERSION)

automake-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://ftp.gnu.org/gnu/automake/automake-1.17-$(AUTOMAKE_VERSION).tar.gz{$(comma).sig})
	$(call PGP_VERIFY,automake-$(AUTOMAKE_VERSION).tar.gz)
	$(call EXTRACT_TAR,automake-$(AUTOMAKE_VERSION).tar.gz,automake-$(AUTOMAKE_VERSION),automake)

ifneq ($(wildcard $(BUILD_WORK)/automake/.build_complete),)
automake:
	@echo "Using previously built automake."
else
automake: automake-setup
	cd $(BUILD_WORK)/automake && PERL="$(shell command -v perl)" ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/automake
	+$(MAKE) -C $(BUILD_WORK)/automake install \
		DESTDIR=$(BUILD_STAGE)/automake
	$(call AFTER_BUILD,copy)
endif
automake-package: automake-stage
	# automake.mk Package Structure
	rm -rf $(BUILD_DIST)/automake

	# automake.mk Prep automake
	cp -a $(BUILD_STAGE)/automake $(BUILD_DIST)

	# automake.mk Sign
	$(call SIGN,automake,general.xml)

	# automake.mk Make .debs
	$(call PACK,automake,DEB_AUTOMAKE_V)

	# automake.mk Build cleanup
	rm -rf $(BUILD_DIST)/automake

.PHONY: automake automake-package
