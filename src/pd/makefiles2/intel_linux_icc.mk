# Makefile with Genernal Options
#
# CVS Info : $Id: intel_linux_icc.mk 68602 2015-01-23 00:13:11Z sbjang $
#

# ���޵Ǵ� �ܺ� ������ : GCC

# ID_DIR      : SM ���丮 
# ID_ACE_ROOT : ���̺귯�� �н�
# compile64   : ������ ȯ��
# compat5     : CC 5.0 ����?

ifndef	BUILD_MODE
	@echo "ERROR BUILD_MODE!!!!"
	@exit
endif

.SUFFIXES: .cpp .$(OBJEXT) .a

CXX	= icc
CC	= icc
LD	= $(CXX)

AR	= ar
ARFLAGS	= -ruv

NM 	= /usr/bin/nm
NMFLAGS	= -t x

PURIFY		= purify -chain-length=100
QUANTIFY	= quantify
PURECOV		= purecov
PURIFYCOV   = $(PURIFY) $(PURECOV)

# IDL(ACE) Library
# Library

# readline library ����

ifeq "$(USE_READLINE)" "1"
READLINE_INCLUDES = -I/usr/local/include/readline
READLINE_LIBRARY =  -lreadline -ltermcap 
endif # use readline library 



LIBS     = $(READLINE_LIBRARY) -lcxa -lunwind  -ldl -lpthread -lcrypt -lrt -lstdc++  -lcprts

# ��ũ�� ����
CLASSIC_LIB = 
LIB64_DIRS  =
LIB32_DIRS  =

# ACE�� ������ �ɼ��� ��ġ��Ų��.
# inline = -D__ACE_INLINE__ 
# else   =  -DACE_NO_INLINE
#
#ACE_FLAG = -W -Wall -Wpointer-arith -pipe  -O2 -g -fno-implicit-templates   -fno-exceptions -fcheck-new -DACE_NO_INLINE -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER 

# ���� ������ �ɼ� ����
#
EXTRA_CXXOPT  =
EXTRA_LOPT += $(LIB32_DIRS)

#CXXOPT		= -c -Wall -D_POSIX_PTHREAD_SEMANTICS 
CXXOPT		= -c -D_POSIX_PTHREAD_SEMANTICS 
EOPT		= -E -D_POSIX_PTHREAD_SEMANTICS 
SOPT		= -S -D_POSIX_PTHREAD_SEMANTICS 
LOPT		= -L. 
AOPT            =
DEFINES		= -D_REENTRANT

CXXOPT_DEPENDANCY = -MM

# Build Mode file for Makefile 
#
# CVS Info : $Id: intel_linux_icc.mk 68602 2015-01-23 00:13:11Z sbjang $
#

# BUILD_MODE�� ����
#	debug		: Debug ���
#   prerelease      : -DDEBUG(x) -g (o)
#	release		: release ����, ���� product�� �ش�

# LINK MODE ���� 
#	purify		: purify version
#	quantify	: quantify version
#	purecov		: purecov version
#	purifycov   : purifycov version


CXX_VERSION := $(shell $(CXX) -dumpversion)

ifeq (3.4,$(findstring 3.4,$(CXX_VERSION)))
 LIBS := $(LIBS) -lstdc++
 CCFLAGS +=  -Wno-deprecated
endif



ifeq "$(BUILD_MODE)" "debug"
ACE_FLAG = -DACE_NO_INLINE -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER
EXTRA_CXXOPT	+= $(ACE_FLAG) -g $(SOURCE_BROWSER) -DDEBUG
EXTRA_LOPT	+= -g

else
ifeq "$(BUILD_MODE)" "prerelease"
ACE_FLAG = -D__ACE_INLINE__ -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER
EXTRA_CXXOPT	+= $(ACE_FLAG) -g
EXTRA_LOPT	+= -g

else
ifeq "$(BUILD_MODE)" "release"
ACE_FLAG = -D__ACE_INLINE__ -DACE_LACKS_ACE_TOKEN -DACE_LACKS_ACE_OTHER
EXTRA_CXXOPT	+= $(ACE_FLAG) -O3 -funroll-loops
EXTRA_LOPT	+= -O3 -funroll-loops
EXTRA_CXXOPT2	+= $(ACE_FLAG) -funroll-loops
else
error:
	@echo "ERROR!!!! UNKNOWN BUILD_MODE($(BUILD_MODE))";
	@exit;

endif	# release
endif   # prerelease
endif	# debug

############### LINK MODE #####################################3
ifeq "$(LINK_MODE)" "normal"
LD		:=  $(LD)

else
ifeq "$(LINK_MODE)" "purify"
  ifeq "$(OS_TARGET)" "HP_HPUX"
    LD		:= $(PURIFY) -collector=/usr/ccs/bin/ld $(LD)
  else
    LD		:= $(PURIFY) $(LD)
  endif
else
ifeq "$(LINK_MODE)" "quantify"
LD		:= $(QUANTIFY) $(LD)

else
ifeq "$(LINK_MODE)" "purecov"
LD		:= $(PURECOV) $(LD)

else
ifeq "$(LINK_MODE)" "purifycov"
LD		:= $(PURIFYCOV) $(LD)
else
error:
	@echo "ERROR!!!! UNKNOWN LINK_MODE($(LINK_MODE))";
	@exit;

endif	# purifycov
endif	# purecov
endif	# quantify
endif	# purify
endif	# normal

CXXFLAGS	= $(CXXOPT) $(EXTRA_CXXOPT)
CXXFLAGS2	= $(CXXOPT) $(EXTRA_CXXOPT2)

EFLAGS	= $(EOPT) $(EXTRA_CXXOPT)
SFLAGS	= $(SOPT) $(EXTRA_CXXOPT)
LFLAGS	= $(LOPT) $(EXTRA_LOPT)
CCFLAGS := -D_GNU_SOURCE $(CCFLAGS) 
SOLFLAGS = -rdynamic

#############################
#  Choose Altibase Build    # 
#############################

# some platform like windows don;t have enough shell buffer for linking. 
# so use indirection file for linking.
NEED_INDIRECTION_BUILD = no

# some platform like aix 4.3 don't need to build shared library 
NEED_SHARED_LIBRARY = yes

# some platform like suse linux/windows have a problem for using libedit.
NEED_BUILD_LIBEDIT = yes

# some platform like a windows don;t have to build jdbc 
NEED_BUILD_JDBC = yes