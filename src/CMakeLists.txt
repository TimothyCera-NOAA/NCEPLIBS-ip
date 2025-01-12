# This is the CMake file for the src directory of NCEPLIBS-ip.
#
# Alex Richert, Mark Potts, Kyle Gerheiser, Ed Hartnett, Eric Engle

# These are the source code filees.
set(fortran_src gdswzd_c.F90 gdswzd_mod.F90 ipolates.F90 ipolatev.F90
ipxetas.F90 ipxwafs.F90 ipxwafs2.F90 ipxwafs3.F90 movect.F90
bilinear_interp_mod.F90 bicubic_interp_mod.F90 neighbor_interp_mod.F90
budget_interp_mod.F90 spectral_interp_mod.F90 neighbor_budget_interp_mod.F90
ip_mod.F90 ip_grid_descriptor_mod.F90 ip_grid_mod.F90
ip_station_points_grid_mod.F90 ip_gaussian_grid_mod.F90
ip_equid_cylind_grid_mod.F90 ip_lambert_conf_grid_mod.F90
ip_mercator_grid_mod.F90 ip_polar_stereo_grid_mod.F90
ip_rot_equid_cylind_egrid_mod.F90 ip_rot_equid_cylind_grid_mod.F90
ip_constants_mod.F90 ip_grids_mod.F90 ip_grid_factory_mod.F90
ip_interpolators_mod.F90 earth_radius_mod.F90 polfix_mod.F90
fftpack.F lapack_gen.F ncpus.F spanaly.f spdz2uv.f speps.f spfft1.f spffte.f
spfftpt.f splaplac.f splat.F splegend.f sppad.f spsynth.f sptezd.f sptez.f
sptezmd.f sptezm.f sptezmv.f sptezv.f sptgpm.f sptgpmv.f sptgps.f sptgpsv.f
sptgpt.f sptgptv.f sptrand.f sptran.f sptranf0.f sptranf1.f sptranf.f sptranfv.f
sptranv.f sptrun.f sptrung.f sptrungv.f sptrunm.f sptrunmv.f sptruns.f
sptrunsv.f sptrunv.f spuv2dz.f spwget.f)

if(BUILD_DEPRECATED)
  set(fortran_src ${fortran_src} spfft.f spgradq.f spgradx.f spgrady.f sptgpmd.f
  sptgpsd.f sptgptd.f sptgptsd.f sptgptvd.f sptrund.f sptrunl.f spvar.f)
endif()

set_source_files_properties(fftpack.F PROPERTIES COMPILE_FLAGS -fcheck=no-bounds)
set_source_files_properties(sptranf.f PROPERTIES COMPILE_FLAGS -fcheck=no-bounds)
set_source_files_properties(sptranfv.f PROPERTIES COMPILE_FLAGS -fcheck=no-bounds)

# Build _4, _d, and/or _8 depending on options provided to CMake
foreach(kind ${kinds})
  set(lib_name ${PROJECT_NAME}_${kind})
  set(module_dir "${CMAKE_CURRENT_BINARY_DIR}/include_${kind}")

  # Create the C header files for this kind.
  configure_file(iplib_${kind}.h ${CMAKE_CURRENT_BINARY_DIR}/include_${kind}/iplib.h COPYONLY)

  # Compiled with preprocessor definition LSIZE=D, not d
  string(TOUPPER ${kind} kind_definition)

  # Build the library.
  add_library(${lib_name} ${fortran_src})
  add_library(${PROJECT_NAME}::${lib_name} ALIAS ${lib_name})
  
  # For shared, set SOVERSION; increment it if API changes (other than
  # adding new functions).
  if(BUILD_SHARED_LIBS)
    set_target_properties(${lib_name} PROPERTIES SOVERSION 0)
  endif()

  # Set compiler flags.
  target_compile_definitions(${lib_name} PRIVATE "LSIZE=${kind_definition}")
  set_target_properties(${lib_name} PROPERTIES COMPILE_FLAGS "${fortran_${kind}_flags}")
  set_target_properties(${lib_name} PROPERTIES Fortran_MODULE_DIRECTORY "${module_dir}")
  target_include_directories(${lib_name}
    PUBLIC $<BUILD_INTERFACE:${module_dir}> $<INSTALL_INTERFACE:include_${kind}>)

  # Handle OpenMP.
  if(OpenMP_Fortran_FOUND)
    target_link_libraries(${lib_name} PUBLIC OpenMP::OpenMP_Fortran)
  endif()
  
  list(APPEND LIB_TARGETS ${lib_name})
  
  install(DIRECTORY ${module_dir} DESTINATION ${CMAKE_INSTALL_PREFIX})
  install(FILES iplib_${kind}.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include_${kind} RENAME iplib.h)
endforeach()

# Install the library or libraries.
install(
  TARGETS ${LIB_TARGETS}
  EXPORT ${PROJECT_NAME}Exports
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

### Package config
include(CMakePackageConfigHelpers)
set(CONFIG_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

export(EXPORT ${PROJECT_NAME}Exports
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}-targets.cmake)

configure_package_config_file(
  ${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
  INSTALL_DESTINATION ${CONFIG_INSTALL_DESTINATION})
install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

write_basic_package_version_file(
  ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})

install(EXPORT ${PROJECT_NAME}Exports
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}-targets.cmake
  DESTINATION ${CONFIG_INSTALL_DESTINATION})
