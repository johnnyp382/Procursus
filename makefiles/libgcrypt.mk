ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS     += libgcrypt
LIBGCRYPT_VERSION := 1.11.0
DEB_LIBGCRYPT_V   ?= $(LIBGCRYPT_VERSION)

libgcrypt-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE),https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$(LIBGCRYPT_VERSION).tar.bz2{$(comma).sig})
	$(call PGP_VERIFY,libgcrypt-$(LIBGCRYPT_VERSION).tar.bz2)
	$(call EXTRACT_TAR,libgcrypt-$(LIBGCRYPT_VERSION).tar.bz2,libgcrypt-$(LIBGCRYPT_VERSION),libgcrypt)

ifneq ($(wildcard $(BUILD_WORK)/libgcrypt/.build_complete),)
libgcrypt:
	@echo "Using previously built libgcrypt."
else
libgcrypt: libgcrypt-setup libgpg-error
	for ASM in $(BUILD_WORK)/libgcrypt/mpi/aarch64/*.S; do \
		sed -i '/.type/d' $$ASM; \
		sed -i '/.size/d' $$ASM; \
		sed -i 's/_gcry/__gcry/g' $$ASM; \
	done
	for ASM in $(BUILD_WORK)/libgcrypt/mpi/amd64/*.S; do \
		sed -i 's/_gcry/__gcry/g' $$ASM; \
	done
	cd $(BUILD_WORK)/libgcrypt && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-gpg-error-prefix=$(BUILD_BASE)$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	+$(MAKE) -C $(BUILD_WORK)/libgcrypt
	+$(MAKE) -C $(BUILD_WORK)/libgcrypt install \
		DESTDIR=$(BUILD_STAGE)/libgcrypt
	$(call AFTER_BUILD,copy)
endif

libgcrypt-package: libgcrypt-stage
	# libgcrypt.mk Package Structure
	rm -rf $(BUILD_DIST)/libgcrypt20{,-dev}
	mkdir -p $(BUILD_DIST)/libgcrypt20/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	mkdir -p $(BUILD_DIST)/libgcrypt20-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libgcrypt.mk Prep libgcrypt
	cp -a $(BUILD_STAGE)/libgcrypt/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libgcrypt.20.dylib $(BUILD_DIST)/libgcrypt20/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/libgcrypt/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{bin,share} $(BUILD_DIST)/libgcrypt20-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/libgcrypt/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libgcrypt20-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/libgcrypt/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libgcrypt.{dylib,a} $(BUILD_DIST)/libgcrypt20-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# libgcrypt.mk Sign
	$(call SIGN,libgcrypt20,general.xml)
	$(call SIGN,libgcrypt20-dev,general.xml)

	# libgcrypt.mk Make .debs
	$(call PACK,libgcrypt20,DEB_LIBGCRYPT_V)
	$(call PACK,libgcrypt20-dev,DEB_LIBGCRYPT_V)

	# libgcrypt.mk Build cleanup
	rm -rf $(BUILD_DIST)/libgcrypt20{,-dev}

.PHONY: libgcrypt libgcrypt-package
