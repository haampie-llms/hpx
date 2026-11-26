# Copyright (c)      2020 ETH Zurich
#
# SPDX-License-Identifier: BSL-1.0
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

# hipcc compiles HIP sources as C++, with other C++ compilers they use the HIP
# language
if(HPX_WITH_HIP AND NOT CMAKE_CXX_COMPILER MATCHES "hipcc$")
  set(HPX_HIP_LANGUAGE HIP)

  if(NOT DEFINED CMAKE_HIP_STANDARD)
    set(CMAKE_HIP_STANDARD ${HPX_CXX_STANDARD})
  elseif(CMAKE_HIP_STANDARD LESS 20)
    hpx_error(
      "You've set CMAKE_HIP_STANDARD to ${CMAKE_HIP_STANDARD}, which is less than 20 (the minimum required by HPX)"
    )
  endif()
  set(CMAKE_HIP_STANDARD_REQUIRED ON)
  set(CMAKE_HIP_EXTENSIONS OFF)

  enable_language(HIP)

  # the HIP runtime for the sources compiled by the C++ compiler
  include(HPX_HIPPrefixPath)
  hpx_add_hip_prefix_path()
  find_package(hip REQUIRED CONFIG)
  if(NOT HPX_FIND_PACKAGE)
    target_link_libraries(hpx_base_libraries INTERFACE hip::host)
  endif()
else()
  set(HPX_HIP_LANGUAGE CXX)
endif()

if(HPX_WITH_HIP AND NOT TARGET roc::hipblas)

  if(HPX_WITH_CUDA)
    hpx_error(
      "Both HPX_WITH_CUDA and HPX_WITH_HIP are ON. Please choose one of \
    them for HPX to work properly"
    )
  endif(HPX_WITH_CUDA)

  include(HPX_HIPPrefixPath)
  hpx_add_hip_prefix_path()
  # Setup hipblas (creates roc::hipblas)
  find_package(hipblas HINTS $ENV{HIPBLAS_ROOT} CONFIG)
  if(NOT hipblas_FOUND)
    hpx_warn(
      "Hipblas could not be found, the blas parts will therefore be disabled.\n\
      You can reconfigure specifying HIPBLAS_ROOT environment variable to enable hipblas"
    )
    set(HPX_WITH_GPUBLAS OFF)
  else()
    set(HPX_WITH_GPUBLAS ON)
    if(NOT HPX_FIND_PACKAGE)
      hpx_add_config_define(HPX_HAVE_GPUBLAS)
    endif()
  endif()

  if(NOT HPX_FIND_PACKAGE)
    # The cmake variables are supposed to be cached no need to redefine them
    set(HPX_WITH_COMPUTE ON)
    hpx_add_config_define(HPX_HAVE_COMPUTE)
    hpx_add_config_define(HPX_HAVE_HIP)
  endif()

endif()

# rocThrust for the thrust module (creates roc::rocthrust); also needed by
# projects using HPX, which get it through the thrust module's link interface
if(HPX_WITH_HIP
   AND HPX_WITH_THRUST
   AND NOT TARGET roc::rocthrust
)
  find_package(rocthrust REQUIRED CONFIG)
endif()
