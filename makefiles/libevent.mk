ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += libevent
LIBEVENT_VERSION   := 2.1.12-1
DEB_LIBEVENT_V     ?= $(LIBEVENT_VERSION)-3

# Repositories
# You can replace them with your own fork.
REPO_URL	:= https://github.com/libevent/libevent

ifneq ($(wildcard $(BUILD_WORK)/libevent/.build_complete),)
libevent:
	@echo "Using previously built libevent."
else
libevent:
	cd $(BUILD_WORK) && git clone $(REPO_URL) && cd ../
	cd $(BUILD_WORK)/libevent && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		-DEVENT__LIBRARY_TYPE:STRING=BOTH \
		.
	+$(MAKE) -C $(BUILD_WORK)/libevent install \
		DESTDIR=$(BUILD_STAGE)/libevent
	$(call AFTER_BUILD,copy)
endif

libevent-package: libevent-stage
	# libevent.mk Package Structure
	rm -rf $(BUILD_DIST)/libevent-{{core-,extra-,openssl-,pthreads-,}2.1-7,dev}
	mkdir -p \
		$(BUILD_DIST)/libevent-{core-,extra-,openssl-,pthreads-,}2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libevent-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/

	# libevent.mk Prep libevent-2.1-7
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent-2.1.7.dylib $(BUILD_DIST)/libevent-2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Prep libevent-core-2.1-7
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent_core-2.1.7.dylib $(BUILD_DIST)/libevent-core-2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Prep libevent-dev
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libevent-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pkgconfig $(BUILD_DIST)/libevent-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent{_{core,extra,openssl,pthreads},}.{a,dylib} $(BUILD_DIST)/libevent-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Prep libevent-extra-2.1-7
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent_extra-2.1.7.dylib $(BUILD_DIST)/libevent-extra-2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Prep libevent-openssl-2.1-7
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent_openssl-2.1.7.dylib $(BUILD_DIST)/libevent-openssl-2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Prep libevent-pthreads-2.1-7
	cp -a $(BUILD_STAGE)/libevent/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libevent_pthreads-2.1.7.dylib $(BUILD_DIST)/libevent-pthreads-2.1-7/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libevent.mk Sign
	$(call SIGN,libevent-2.1-7,general.xml)
	$(call SIGN,libevent-core-2.1-7,general.xml)
	$(call SIGN,libevent-dev,general.xml)
	$(call SIGN,libevent-extra-2.1-7,general.xml)
	$(call SIGN,libevent-openssl-2.1-7,general.xml)
	$(call SIGN,libevent-pthreads-2.1-7,general.xml)

	# libevent.mk Make .debs
	$(call PACK,libevent-2.1-7,DEB_LIBEVENT_V)
	$(call PACK,libevent-core-2.1-7,DEB_LIBEVENT_V)
	$(call PACK,libevent-dev,DEB_LIBEVENT_V)
	$(call PACK,libevent-extra-2.1-7,DEB_LIBEVENT_V)
	$(call PACK,libevent-openssl-2.1-7,DEB_LIBEVENT_V)
	$(call PACK,libevent-pthreads-2.1-7,DEB_LIBEVENT_V)

	# libevent.mk Build cleanup
	rm -rf $(BUILD_DIST)/libevent-{{core-,extra-,openssl-,pthreads-,}2.1-7,dev}

.PHONY: libevent libevent-package
