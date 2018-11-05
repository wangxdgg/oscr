# - Find the NumPy libraries
# This module finds if NumPy is installed, and sets the following variables
# indicating where it is.
#
# TODO: Update to provide the libraries and paths for linking npymath lib.
#
#  NUMPY_FOUND               - was NumPy found
#  NUMPY_VERSION             - the version of NumPy found as a string
#  NUMPY_VERSION_MAJOR       - the major version number of NumPy
#  NUMPY_VERSION_MINOR       - the minor version number of NumPy
#  NUMPY_VERSION_PATCH       - the patch version number of NumPy
#  NUMPY_VERSION_DECIMAL     - e.g. version 1.6.1 is 10601
#  NUMPY_INCLUDE_DIRS        - path to the NumPy include files

# from: https://raw.githubusercontent.com/pydata/numexpr/master/FindNumPy.cmake
#============================================================================
# Copyright 2012 Continuum Analytics, Inc.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#============================================================================

# Finding NumPy involves calling the Python interpreter
IF(NumPy_FIND_REQUIRED)
  FIND_PACKAGE(PythonInterp REQUIRED)
ELSE()
  FIND_PACKAGE(PythonInterp)
ENDIF()

IF(NOT PYTHONINTERP_FOUND)
  SET(NUMPY_FOUND FALSE)
  RETURN()
ENDIF()

EXECUTE_PROCESS(
  COMMAND "${PYTHON_EXECUTABLE}" "-c"
  "import numpy as n; print(n.__version__); print(n.get_include());"
  RESULT_VARIABLE _NUMPY_SEARCH_SUCCESS
  OUTPUT_VARIABLE _NUMPY_VALUES_OUTPUT
  ERROR_VARIABLE _NUMPY_ERROR_VALUE
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )

IF(NOT _NUMPY_SEARCH_SUCCESS MATCHES 0)
  IF(NumPy_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR
      "NumPy import failure:\n${_NUMPY_ERROR_VALUE}")
  ENDIF()
  SET(NUMPY_FOUND FALSE)
  RETURN()
ENDIF()

# Convert the process output into a list
STRING(REGEX REPLACE ";" "\\\\;" _NUMPY_VALUES ${_NUMPY_VALUES_OUTPUT})
STRING(REGEX REPLACE "\n" ";" _NUMPY_VALUES ${_NUMPY_VALUES})
# Just in case there is unexpected output from the Python command.
LIST(GET _NUMPY_VALUES -2 NUMPY_VERSION)
LIST(GET _NUMPY_VALUES -1 NUMPY_INCLUDE_DIRS)

STRING(REGEX MATCH "^[0-9]+\\.[0-9]+\\.[0-9]+" _VER_CHECK "${NUMPY_VERSION}")
IF("${_VER_CHECK}" STREQUAL "")
  # The output from Python was unexpected. Raise an error always here, because
  # we found NumPy, but it appears to be corrupted somehow.
  MESSAGE(FATAL_ERROR
    "Requested version and include path from NumPy, got instead:\n${_NUMPY_VALUES_OUTPUT}\n")
  RETURN()
ENDIF()

# Make sure all directory separators are '/'
STRING(REGEX REPLACE "\\\\" "/" NUMPY_INCLUDE_DIRS ${NUMPY_INCLUDE_DIRS})

# Get the major and minor version numbers
STRING(REGEX REPLACE "\\." ";" _NUMPY_VERSION_LIST ${NUMPY_VERSION})
LIST(GET _NUMPY_VERSION_LIST 0 NUMPY_VERSION_MAJOR)
LIST(GET _NUMPY_VERSION_LIST 1 NUMPY_VERSION_MINOR)
LIST(GET _NUMPY_VERSION_LIST 2 NUMPY_VERSION_PATCH)
STRING(REGEX MATCH "[0-9]*" NUMPY_VERSION_PATCH ${NUMPY_VERSION_PATCH})
MATH(
  EXPR NUMPY_VERSION_DECIMAL
  "(${NUMPY_VERSION_MAJOR} * 10000) + (${NUMPY_VERSION_MINOR} * 100) + ${NUMPY_VERSION_PATCH}")

FIND_PACKAGE_MESSAGE(NUMPY
  "Found NumPy: version \"${NUMPY_VERSION}\" ${NUMPY_INCLUDE_DIRS}"
  "${NUMPY_INCLUDE_DIRS}${NUMPY_VERSION}"
  )

SET(NUMPY_FOUND TRUE)


