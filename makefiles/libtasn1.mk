ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS    += libtasn1
LIBTASN1_VERSION := 4.19.0-1
DEB_LIBTASN1_V   ?= $(LIBTASN1_VERSION)

# Repositories
# You can replace them with your own fork.
REPO_URL	:= https://github.com/gnutls/libtasn1

ifneq ($(wildcard $(BUILD_WORK)/libtasn1/.build_complete),)
jansson:
	@echo "Using previously built libtasn1."
else
libtasn1:
	cd $(BUILD_WORK) && git clone $(REPO_URL) && cd ../
	cd $(BUILD_WORK)/libtasn1 && ./bootstrap && cd ../
	cd $(BUILD_WORK)/libtasn1 && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/libtasn1
	+$(MAKE) -C $(BUILD_WORK)/libtasn1 install \
		DESTDIR=$(BUILD_STAGE)/libtasn1
	$(call AFTER_BUILD,copy)
endif

libtasn1-package: libtasn1-stage
	# libtasn1.mk Package Structure
	rm -rf $(BUILD_DIST)/libtasn1-{6{,-dev},bin}
	mkdir -p $(BUILD_DIST)/libtasn1-6/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libtasn1-6-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib,share/man} \
		$(BUILD_DIST)/libtasn1-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man

	# libtasn1.mk Prep libtasn1-6
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libtasn1.6.dylib $(BUILD_DIST)/libtasn1-6/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libtasn1.mk Prep libtasn1-dev
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libtasn1.6.dylib) $(BUILD_DIST)/libtasn1-6-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man3 $(BUILD_DIST)/libtasn1-6-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libtasn1-6-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libtasn1.mk Prep libtasn1-bin
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man/man1 $(BUILD_DIST)/libtasn1-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/man
	cp -a $(BUILD_STAGE)/libtasn1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin $(BUILD_DIST)/libtasn1-bin/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# libtasn1.mk Sign
	$(call SIGN,libtasn1-6,general.xml)
	$(call SIGN,libtasn1-bin,general.xml)

	# libtasn1.mk Make .debs
	$(call PACK,libtasn1-6,DEB_LIBTASN1_V)
	$(call PACK,libtasn1-bin,DEB_LIBTASN1_V)
	$(call PACK,libtasn1-6-dev,DEB_LIBTASN1_V)

	# libtasn1.mk Build cleanup
	rm -rf $(BUILD_DIST)/libtasn1-{6{,-dev},bin}

.PHONY: libtasn1 libtasn1-package
