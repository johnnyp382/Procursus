ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS     += jansson
JANSSON_VERSION := 2.14-1
DEB_JANSSON_V   ?= $(JANSSON_VERSION)

# Repositories
# You can replace them with your own fork.
REPO_URL	:= https://github.com/akheron/jansson

ifneq ($(wildcard $(BUILD_WORK)/jansson/.build_complete),)
jansson:
	@echo "Using previously built jansson."
else
jansson:
	cd $(BUILD_WORK) && git clone $(REPO_URL)
	autoreconf --install $(BUILD_WORK)/jansson && cd ../
	cd $(BUILD_WORK)/jansson && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/jansson
	+$(MAKE) -C $(BUILD_WORK)/jansson install \
		DESTDIR="$(BUILD_STAGE)/jansson"
	$(call AFTER_BUILD,copy)
endif


jansson-package: jansson-stage
	# jansson.mk Package Structure
	rm -rf $(BUILD_DIST)/libjansson{4,-dev}
	mkdir -p $(BUILD_DIST)/libjansson{4,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# jansson.mk Prep libjanssson-dev
	cp -a $(BUILD_STAGE)/jansson/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libjansson-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include
	cp -a $(BUILD_STAGE)/jansson/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libjansson.{a,dylib} $(BUILD_DIST)/libjansson-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/jansson/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pkgconfig $(BUILD_DIST)/libjansson-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# jansson.mk Prep libjansson4
	cp -a $(BUILD_STAGE)/jansson/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libjansson.4.dylib $(BUILD_DIST)/libjansson4/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# jansson.mk Sign
	$(call SIGN,libjansson-dev,general.xml)
	$(call SIGN,libjansson4,general.xml)

	# jansson.mk Make .debs
	$(call PACK,libjansson-dev,DEB_JANSSON_V)
	$(call PACK,libjansson4,DEB_JANSSON_V)

	# jansson.mk Build cleanup
	rm -rf $(BUILD_DIST)/libjansson{4,-dev}

.PHONY: jansson jansson-package
