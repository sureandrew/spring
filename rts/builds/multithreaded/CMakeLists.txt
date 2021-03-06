# Place executables and shared libs under "build-dir/",
# instead of under "build-dir/rts/"
# This way, we have the build-dir structure more like the install-dir one,
# which makes testing spring in the builddir easier, eg. like this:
# cd build-dir
# SPRING_DATADIR=$(pwd) ./spring
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")


### Assemble defines
ADD_DEFINITIONS(-DUSE_GML)
# USE_GML requires this
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mno-tls-direct-seg-refs")

# USE_GML_SIM requires USE_GML
ADD_DEFINITIONS(-DUSE_GML_SIM)

if (USE_GML_DEBUG)
	ADD_DEFINITIONS(-DUSE_GML_DEBUG)
endif (USE_GML_DEBUG)


### Assemble libraries
FIND_PACKAGE(SDL REQUIRED)
INCLUDE_DIRECTORIES(${SDL_INCLUDE_DIR})
LIST(APPEND engineLibraries ${SDL_LIBRARY})


FIND_PACKAGE_STATIC(OpenGL REQUIRED)
FIND_PACKAGE_STATIC(GLU REQUIRED)
FIND_PACKAGE_STATIC(GLEW 1.5.1 REQUIRED)
LIST(APPEND engineLibraries ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY} ${GLEW_LIBRARIES})


FIND_PACKAGE_STATIC(Freetype REQUIRED)
INCLUDE_DIRECTORIES(${FREETYPE_INCLUDE_DIRS})
LIST(APPEND engineLibraries ${FREETYPE_LIBRARIES})

IF    (PREFER_STATIC_LIBS)
	# dependencies of FreeType
	FIND_PACKAGE_STATIC(BZip2 REQUIRED)
	LIST(APPEND engineLibraries ${BZIP2_LIBRARIES})
ENDIF (PREFER_STATIC_LIBS)

IF    (UNIX)
	FIND_PACKAGE_STATIC(X11 REQUIRED)
	LIST(APPEND engineLibraries ${X11_Xcursor_LIB} ${X11_X11_LIB})

	IF    (PREFER_STATIC_LIBS)
		# dependencies of X11/XCursor
		FIND_PACKAGE_STATIC(XCB REQUIRED)
		LIST(APPEND engineLibraries ${X11_Xrender_LIB} ${X11_Xfixes_LIB} ${XCB_LIBRARIES} ${X11_Xau_LIB} ${X11_Xdmcp_LIB})
	ENDIF (PREFER_STATIC_LIBS)
ENDIF (UNIX)

IF (APPLE)
	FIND_LIBRARY(COREFOUNDATION_LIBRARY Foundation)
	LIST(APPEND engineLibraries ${COREFOUNDATION_LIBRARY})
ENDIF (APPLE)

LIST(APPEND engineLibraries ${sound-impl})

LIST(APPEND engineLibraries ${engineCommonLibraries})

INCLUDE_DIRECTORIES(${ENGINE_SRC_ROOT_DIR}/lib/assimp/include)


### Assemble external incude dirs
INCLUDE_DIRECTORIES(${OPENAL_INCLUDE_DIR})


### Add icon and manifest to exe using windres
IF    (WIN32)
	SET(ENGINE_ICON_GML_DIR "${ENGINE_SRC_ROOT_DIR}")
	SET(ENGINE_ICON_GML_RES "${ENGINE_SRC_ROOT_DIR}/icon.rc")
	SET(ENGINE_ICON_GML_OBJ "${CMAKE_CURRENT_BINARY_DIR}/icon.o")
	CreateResourceCompileCommand(ENGINE_ICON_GML "${ENGINE_ICON_GML_DIR}" "${ENGINE_ICON_GML_RES}" "${ENGINE_ICON_GML_OBJ}")
ELSE  (WIN32)
	SET(ENGINE_ICON_GML "")
ENDIF (WIN32)


### Build the executable
ADD_EXECUTABLE(engine-multithreaded ${engineSources} ${ENGINE_ICON_GML} ${engineHeaders})
TARGET_LINK_LIBRARIES(engine-multithreaded gml ${engineLibraries})
SET_TARGET_PROPERTIES(engine-multithreaded PROPERTIES OUTPUT_NAME "spring-multithreaded")


### Install the executable
INSTALL(TARGETS engine-multithreaded DESTINATION ${BINDIR})

# Only build & install spring-multithreaded executable & dependencies
# use cases:
# * make spring-multithreaded
# * make install-spring-multithreaded
CreateEngineBuildAndInstallTarget(multithreaded)

