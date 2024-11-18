ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += perl
PERL_MAJOR   := 5.41
PERL_VERSION := $(PERL_MAJOR).1
PERL_API_V   := $(PERL_MAJOR).0
PERL_CROSS_V := 1.6
DEB_PERL_V   ?= $(PERL_VERSION)

export PERL_MAJOR

perl-setup: setup
	$(call DOWNLOAD_FILES,$(BUILD_SOURCE), https://www.cpan.org/src/5.0/perl-$(PERL_VERSION).tar.gz \
		https://github.com/arsv/perl-cross/releases/download/$(PERL_CROSS_V)/perl-cross-$(PERL_CROSS_V).tar.gz)
	rm -rf $(BUILD_WORK)/perl
	$(call EXTRACT_TAR,perl-$(PERL_VERSION).tar.gz,perl-$(PERL_VERSION),perl)
	chmod -R +w $(BUILD_WORK)/perl
	$(call EXTRACT_TAR,perl-cross-$(PERL_CROSS_V).tar.gz,perl-cross-$(PERL_CROSS_V),perl,1)
	sed -i 's/readelf --syms/nm -g/g' $(BUILD_WORK)/perl/cnf/configure_type.sh
	sed -i 's/readelf/nm/g' $(BUILD_WORK)/perl/cnf/configure__f.sh
	sed -i 's/readelf/nm/g' $(BUILD_WORK)/perl/cnf/configure_tool.sh
	sed -i 's/bsd/darwin/g' $(BUILD_WORK)/perl/cnf/configure_tool.sh
	sed -i 's/BSD/Darwin/g' $(BUILD_WORK)/perl/cnf/configure_tool.sh
	sed -i '/try_link/ s/$$/ -Wno-error=implicit-function-declaration/' $(BUILD_WORK)/perl/cnf/configure_func.sh
	sed -i '/-Wl,-E/ s/^/#/' $(BUILD_WORK)/perl/cnf/configure_tool.sh
	sed -i '/-Wl,-E/ s/^/#/' $(BUILD_WORK)/perl/Makefile
	sed -i 's/$$(CC) $$(LDDLFLAGS)/$$(CC) $$(LDDLFLAGS) -compatibility_version $(PERL_API_V) -current_version $(PERL_VERSION) -install_name $$(archlib)\/CORE\/$$@/g' $(BUILD_WORK)/perl/Makefile
	sed -i 's/| $$Is{Android}/| $$Is{Darwin}/g' $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Darwin.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MY.pm
	sed -i 's/$$Is{Android} )/$$Is{Darwin} )/g' $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Darwin.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MY.pm
	sed -i '/$$Is{Solaris} =/a \ \ \ \ $$Is{Darwin}  = $$^O eq '\''darwin'\'';' $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Unix.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MM_Darwin.pm $(BUILD_WORK)/perl/cpan/ExtUtils-MakeMaker/lib/ExtUtils/MY.pm
	sed -i "s/&& $$^O ne 'darwin' //" $(BUILD_WORK)/perl/ext/Errno/Errno_pm.PL
	sed -i "s/$$^O eq 'linux'/\$$Config{gccversion} ne ''/" $(BUILD_WORK)/perl/ext/Errno/Errno_pm.PL
	sed -i 's/--sysroot=$$sysroot/-isysroot $$sysroot -arch $(MEMO_ARCH) $(PLATFORM_VERSION_MIN)/' $(BUILD_WORK)/perl/cnf/configure_tool.sh
	sed -i 's|#include "poll.h"|#include "$(TARGET_SYSROOT)/usr/include/poll.h"|g' $(BUILD_WORK)/perl/dist/IO/IO.xs
	touch $(BUILD_WORK)/perl/cnf/hints/darwin
	echo -e "# Linux syscalls\n\
	d_voidsig='undef'\n\
	d_nanosleep='define'\n\
	d_clock_gettime='define'\n\
	d_clock_getres='define'\n\
	d_clock_nanosleep='undef'\n\
	d_clock='define'\n\
	byteorder='12345678'\n\
	libperl='libperl.dylib'" > $(BUILD_WORK)/perl/cnf/hints/darwin

ifneq ($(wildcard $(BUILD_WORK)/perl/.build_complete),)
perl:
	@echo "Using previously built perl."
else
perl: perl-setup
	cd $(BUILD_WORK)/perl && \
	CC='$(CC)' AR='$(AR)' NM='$(NM)' OBJDUMP='objdump' \
	HOSTCFLAGS='-DPERL_CORE -DUSE_CROSS_COMPILE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 $(CFLAGS_FOR_BUILD)' \
	HOSTLDFLAGS='$(LDFLAGS_FOR_BUILD)' \
	CFLAGS='-DPERL_DARWIN -DPERL_USE_SAFE_PUTENV -DTIME_HIRES_CLOCKID_T -DLIBIOSEXEC_INTERNAL=1 $(patsubst -flto=thin,,$(CFLAGS))' \
	LDFLAGS='$(patsubst -flto=thin,,$(LDFLAGS))' ./configure -Dextras='Alien Alien::m4 Alien::Alien App::Cpan App::cpanminus CPAN::Perl::Releases App::perlbrew App::a2p App::find2perl App::cpm App::cpm::CLI Carp Data/Dumper Devel/PPPort Devel/SelfStubber Dumpvalue Env Exporter ExtUtils/CBuilder ExtUtils/ParseXS Filter/Simple FindBin Module::Build Module::Signature ExtUtils::InstallPaths ExtUtils::Config Log::Message Log::Message::Simple Module::Install File::Remove Module::ScanDeps App::cpanminus Log::Log4perl Path::Tiny Tie::Array Env Env::Bash Env::Path Config::ENV CPAN::Plugin CPAN::Plugin::Specfile CPAN::HandleConfig Fcntl Capture::Tiny Getopt::Long Sub::Identify Sub::Name Try::Tiny Config::Model Digest::MD5 Encode Encode::Locale File::Copy File::Listing File::Temp Getopt::Long HTML::Entities HTML::HeadParser HTTP::Cookies HTTP::Date HTTP::Negotiate HTTP::Request HTTP::Request::Common HTTP::Response HTTP::Status IO::Select IO::Socket LWP::MediaTypes MIME::Base64 Module::Load Net::FTP Net::HTTP Scalar::Util Try::Tiny URI URI::Escape WWW::RobotRules LWP LWP::Curl LWP::UserAgent Getopt::Long B Devel/Peek Errno ExtUtils/Miniperl Fcntl File/DosGlob File/Find File/Glob FileCache Hash/Util Hash/Util/FieldHash I18N/Langinfo IPC/Open3 NDBM_File Opcode POSIX PerlIO/encoding PerlIO/mmap PerlIO/scalar PerlIO/via Pod/Functions Pod/Html SDBM_File Sys/Hostname Tie/Hash/NamedCapture Tie/Memoize XS/APItest XS/Typemap attributes mro re Archive/Tar AutoLoader CPAN CPAN/Meta CPAN/Meta/Requirements CPAN/Meta/YAML Compress/Raw/Bzip2 Compress/Raw/Zlib Config/Perl/V DB_File Digest Digest/MD5 Digest/SHA Encode ExtUtils/Constant ExtUtils/Install ExtUtils/MakeMaker ExtUtils/Manifest ExtUtils/PL2Bat File/Fetch File/Path File/Temp Filter/Util/Call Getopt/Long HTTP/Tiny IO/Compress IO/Socket/IP IO/Zlib IPC/Cmd IPC/SysV JSON/PP Locale/Maketext/Simple MIME/Base64 Math/BigInt Math/BigInt/FastCalc Memoize Module/Load Module/Load/Conditional Module/Loaded Module/Metadata NEXT Params/Check Perl/OSType PerlIO/via/QuotedPrint Pod/Checker Pod/Escapes Pod/Perldoc Pod/Simple Pod/Usage Scalar/List/Utils Socket Sys/Syslog Term/ANSIColor Term/Cap Term/Table Term::CLI Term/Complete Term/ReadLine Term::ReadLine::Gnu Term::ReadLine::Perl5 Term::CLI::ReadLine Test/Harness Test/Simple Test2/Suite Text/Balanced Text/ParseWords Text/Tabs Tie/RefHash Time/Local Time/Piece Test Text/Abbrev Thread/Queue Thread/Semaphore Tie/File Time/HiRes Term::ReadKey Term::UI YAML Unicode/Collate autodie bignum experimental libnet parent perlfaq podlators version Attribute/Handlers I18N/Collate I18N/LangTags IO Locale/Maketext Math/Complex Module/CoreList Net/Ping PathTools Safe Search/Dict SelfLoader Storable Unicode/Normalize XSLoader' \
		--build=$$($(BUILD_MISC)/config.guess) \
		--target=$(GNU_HOST_TRIPLE) \
		--sysroot=$(TARGET_SYSROOT) \
		--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		-Dextras="Alien Alien::m4 Alien::Alien App::Cpan App::cpanminus CPAN::Perl::Releases App::perlbrew App::a2p App::find2perl App::cpm App::cpm::CLI Carp Data/Dumper Devel/PPPort Devel/SelfStubber Dumpvalue Env Exporter ExtUtils/CBuilder ExtUtils/ParseXS Filter/Simple FindBin Module::Build Module::Signature ExtUtils::InstallPaths ExtUtils::Config Log::Message Log::Message::Simple Module::Install File::Remove Module::ScanDeps App::cpanminus Log::Log4perl Path::Tiny Tie::Array Env Env::Bash Env::Path Config::ENV CPAN::Plugin CPAN::Plugin::Specfile CPAN::HandleConfig Fcntl Capture::Tiny Getopt::Long Sub::Identify Sub::Name Try::Tiny Config::Model Digest::MD5 Encode Encode::Locale File::Copy File::Listing File::Temp Getopt::Long HTML::Entities HTML::HeadParser HTTP::Cookies HTTP::Date HTTP::Negotiate HTTP::Request HTTP::Request::Common HTTP::Response HTTP::Status IO::Select IO::Socket LWP::MediaTypes MIME::Base64 Module::Load Net::FTP Net::HTTP Scalar::Util Try::Tiny URI URI::Escape WWW::RobotRules LWP LWP::Curl LWP::UserAgent Getopt::Long B Devel/Peek Errno ExtUtils/Miniperl Fcntl File/DosGlob File/Find File/Glob FileCache Hash/Util Hash/Util/FieldHash I18N/Langinfo IPC/Open3 NDBM_File Opcode POSIX PerlIO/encoding PerlIO/mmap PerlIO/scalar PerlIO/via Pod/Functions Pod/Html SDBM_File Sys/Hostname Tie/Hash/NamedCapture Tie/Memoize XS/APItest XS/Typemap attributes mro re Archive/Tar AutoLoader CPAN CPAN/Meta CPAN/Meta/Requirements CPAN/Meta/YAML Compress/Raw/Bzip2 Compress/Raw/Zlib Config/Perl/V DB_File Digest Digest/MD5 Digest/SHA Encode ExtUtils/Constant ExtUtils/Install ExtUtils/MakeMaker ExtUtils/Manifest ExtUtils/PL2Bat File/Fetch File/Path File/Temp Filter/Util/Call Getopt/Long HTTP/Tiny IO/Compress IO/Socket/IP IO/Zlib IPC/Cmd IPC/SysV JSON/PP Locale/Maketext/Simple MIME/Base64 Math/BigInt Math/BigInt/FastCalc Memoize Module/Load Module/Load/Conditional Module/Loaded Module/Metadata NEXT Params/Check Perl/OSType PerlIO/via/QuotedPrint Pod/Checker Pod/Escapes Pod/Perldoc Pod/Simple Pod/Usage Scalar/List/Utils Socket Sys/Syslog Term/ANSIColor Term/Cap Term/Table Term::CLI Term/Complete Term/ReadLine Term::ReadLine::Gnu Term::ReadLine::Perl5 Term::CLI::ReadLine Test/Harness Test/Simple Test2/Suite Text/Balanced Text/ParseWords Text/Tabs Tie/RefHash Time/Local Time/Piece Test Text/Abbrev Thread/Queue Thread/Semaphore Tie/File Time/HiRes Term::ReadKey Term::UI YAML Unicode/Collate autodie bignum experimental libnet parent perlfaq podlators version Attribute/Handlers I18N/Collate I18N/LangTags IO Locale/Maketext Math/Complex Module/CoreList Net/Ping PathTools Safe Search/Dict SelfLoader Storable Unicode/Normalize XSLoader" \
		-Dosname='darwin' -Dosvers='22.1.0' -Darchname='darwin' -Dstartperl='#!/var/jb/usr/bin/perl' -Dstartsh='#!/var/jb/bin/sh' -Daphostname='/var/jb/usr/bin/hostname' -Dfull_sed='/var/jb/usr/bin/sed' -Dgroupcat='cat /var/jb/etc/group' -Dhostcat='cat /var/jb/etc/hosts' -Dcppsymbols='_FORTIFY_SOURCE=2 _LP64=1 __BYTE_ORDER__=1234 __GNUC_MINOR__=1 __GNUC__=14 __LITTLE_ENDIAN__=1 __LP64__=1 __MACH__=1 __PIC__=2 __STDC__=1 __aarch64__=1 __pic__=2' \
		-Duseshrplib \
		-Dusevendorprefix \
		-Dvendorprefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		-Dusethreads \
		-Dvendorlib=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/perl5 \
		-Dprivlib=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/perl5/$(PERL_MAJOR) \
		-Darchlib=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/perl5/$(PERL_MAJOR) \
		-Dvendorarch=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/perl5/$(PERL_MAJOR)
	+$(GMAKE -C) $(BUILD_WORK)/perl -j1 \
		PERL_ARCHIVE=$(BUILD_WORK)/perl/libperl.dylib \
		LIBS="$(filter -liosexec,$(LDFLAGS))"
	+$(GMAKE -C) $(BUILD_WORK)/perl install.perl \
		DESTDIR=$(BUILD_STAGE)/perl
	chmod -R u+w $(BUILD_STAGE)/perl/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/perl5/$(PERL_MAJOR)
	$(call AFTER_BUILD)
endif

perl-package: perl-stage
	# perl.mk Package Structure
	rm -rf $(BUILD_DIST)/perl

	# perl.mk Prep perl
	cp -a $(BUILD_STAGE)/perl $(BUILD_DIST)

	# perl.mk Sign
	$(call SIGN,perl,general.xml)

	# perl.mk Make .debs
	$(call PACK,perl,DEB_PERL_V)

	# perl.mk Build cleanup
	rm -rf $(BUILD_DIST)/perl

.PHONY: perl perl-package
