.if ${MODULES:Mlang/tcl}
ERRORS += "Fatal: MODULES = lang/tcl or x11/tk but not both.\nChoose one and set MOD* variables accordingly."
.endif

CATEGORIES +=		x11/tk

MODTK_VERSION ?= 	8.5
MODTCL_VERSION ?= 	${MODTK_VERSION}

.if ${MODTK_VERSION} == 8.5
_MODTK_SPEC = 		tk->=${MODTK_VERSION},<8.6
MODTK_LIB ?=		tk85
.elif ${MODTK_VERSION} == 8.6
_MODTK_SPEC = 		tk->=${MODTK_VERSION},<8.7
MODTK_LIB ?=		tk86
.endif

MODTK_BIN ?=		${LOCALBASE}/bin/wish${MODTK_VERSION}
MODTK_INCDIR ?=		${LOCALBASE}/include/tk${MODTK_VERSION}
MODTK_LIBDIR ?=		${MODTCL_TCLDIR}/tk${MODTK_VERSION}
MODTK_CONFIG ?=		${MODTK_LIBDIR}/tkConfig.sh


SUBST_VARS +=		MODTK_VERSION MODTK_BIN

MODULES +=		lang/tcl

MODTK_BUILD_DEPENDS ?=	${_MODTK_SPEC}:x11/tk/${MODTK_VERSION} \
			${MODTCL_BUILD_DEPENDS}
MODTK_RUN_DEPENDS ?=	${_MODTK_SPEC}:x11/tk/${MODTK_VERSION} \
			${MODTCL_RUN_DEPENDS}
MODTK_LIB_DEPENDS ?=	${_MODTK_SPEC}:x11/tk/${MODTK_VERSION} \
			${MODTCL_LIB_DEPENDS}
MODTK_WANTLIB ?= 	${MODTK_LIB} ${MODTCL_WANTLIB}