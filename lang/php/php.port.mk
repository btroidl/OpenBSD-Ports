CATEGORIES+=		lang/php

# PHP 8.1+ has non-optional "fibers" code which requires either
# MD code (which PHP doesn't have for sparc64) or ucontext,
# which OpenBSD doesn't have.
#
# also see DEFAULT_PHP setting in subdirs, which controls whether
# to install /usr/local/bin/php and similar symlinks (which can't
# really handle sparc64 being different because that needs conflicts)
#
.if ${MACHINE_ARCH} == sparc64
MODPHP_VERSION?=	8.0
.else
MODPHP_VERSION?=	8.1
.endif

# for ports which force a newer MODPHP_VERSION, disable on sparc64.
.if (${MODPHP_VERSION} == 8.1 || ${MODPHP_VERSION} == 8.2)
NOT_FOR_ARCHS+=		sparc64
.endif

.if ${MODPHP_VERSION} == 7.4
MODPHP_FLAVOR = ,php74
MODPHP_VSPEC = >=7.4,<7.5
.elif ${MODPHP_VERSION} == 8.0
MODPHP_FLAVOR = ,php80
MODPHP_VSPEC = >=8.0,<8.1
.elif ${MODPHP_VERSION} == 8.1
MODPHP_FLAVOR = ,php81
MODPHP_VSPEC = >=8.1,<8.2
.elif ${MODPHP_VERSION} == 8.2
MODPHP_FLAVOR = ,php82
MODPHP_VSPEC = >=8.2,<8.3
.endif
MODPHPSPEC = php-${MODPHP_VSPEC}

MODPHP_RUN_DEPENDS=	${MODPHPSPEC}:lang/php/${MODPHP_VERSION}
MODPHP_LIB_DEPENDS=	${MODPHPSPEC}:lang/php/${MODPHP_VERSION}
MODPHP_WANTLIB =	php${MODPHP_VERSION}
_MODPHP_BUILD_DEPENDS=	${MODPHPSPEC}:lang/php/${MODPHP_VERSION}

MODPHP_BUILDDEP?=	No
MODPHP_RUNDEP?=		Yes

.if ${NO_BUILD:L} == "no" && ${MODPHP_BUILDDEP:L} == "yes"
BUILD_DEPENDS+=		${_MODPHP_BUILD_DEPENDS}
.endif
.if ${MODPHP_RUNDEP:L} == "yes"
RUN_DEPENDS+=		${MODPHP_RUN_DEPENDS}
.endif

MODPHP_BIN=		${LOCALBASE}/bin/php-${MODPHP_VERSION}
MODPHP_PHPIZE=		${LOCALBASE}/bin/phpize-${MODPHP_VERSION}
MODPHP_PHP_CONFIG=	${LOCALBASE}/bin/php-config-${MODPHP_VERSION}
MODPHP_INCDIR=		${LOCALBASE}/include/php-${MODPHP_VERSION}
MODPHP_LIBDIR=		${LOCALBASE}/lib/php-${MODPHP_VERSION}

MODPHP_CONFIGURE_ARGS=	--with-php-config=${LOCALBASE}/bin/php-config-${MODPHP_VERSION}
SUBST_VARS+=		MODPHP_VERSION MODPHP_BIN

# build a string that can be included in RUN_DEPENDS to match suitable PDO types
MODPHP_PDO_ALLOWED?=	mysql pgsql sqlite
MODPHP_PDO_PREF?=	sqlite
MODPHP_PDO_DEPENDS=
.for i in $(MODPHP_PDO_PREF) ${MODPHP_PDO_ALLOWED}
.  if !${MODPHP_PDO_DEPENDS:M*pdo_$i*}
MODPHP_PDO_DEPENDS:=	${MODPHP_PDO_DEPENDS}php-pdo_$i-${MODPHP_VSPEC}|
.  endif
.endfor
MODPHP_PDO_DEPENDS:=	${MODPHP_PDO_DEPENDS:S/|$//}:lang/php/${MODPHP_VERSION},-pdo_${MODPHP_PDO_PREF}

MODPHP_DO_PHPIZE?=
.if !empty(MODPHP_DO_PHPIZE)
AUTOCONF_VERSION?=	2.62
AUTOMAKE_VERSION?=	1.9

BUILD_DEPENDS+=		${MODGNU_AUTOCONF_DEPENDS} \
			${MODGNU_AUTOMAKE_DEPENDS}

.if empty(CONFIGURE_STYLE)
CONFIGURE_STYLE=	gnu
.endif

CONFIGURE_ENV+=		AUTOMAKE_VERSION=${AUTOMAKE_VERSION} \
			AUTOCONF_VERSION=${AUTOCONF_VERSION}
CONFIGURE_ARGS+=	${MODPHP_CONFIGURE_ARGS}

pre-configure:
	cd ${WRKSRC} && ${SETENV} ${CONFIGURE_ENV} ${MODPHP_PHPIZE}
.endif

MODPHP_DO_SAMPLE?=
.if !empty(MODPHP_DO_SAMPLE)
PV=		${MODPHP_VERSION}
MODULE_NAME=	${MODPHP_DO_SAMPLE}
SUBST_VARS+=	PV MODULE_NAME
post-install:
	${INSTALL_DATA_DIR} ${PREFIX}/share/examples/php-${MODPHP_VERSION}
	@echo "extension=${MODPHP_DO_SAMPLE}.so" > \
		${PREFIX}/share/examples/php-${MODPHP_VERSION}/${MODPHP_DO_SAMPLE}.ini
.endif