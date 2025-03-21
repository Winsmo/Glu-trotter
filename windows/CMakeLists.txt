# Spécifiez la version minimale de CMake requise
cmake_minimum_required(VERSION 3.14)

# Définissez le nom du projet et les langages utilisés
project(glu_trotter LANGUAGES CXX)

# Le nom de l'exécutable créé pour l'application. Changez ceci pour modifier
# le nom sur le disque de votre application.
set(BINARY_NAME "glu_trotter")

# Optez explicitement pour les comportements modernes de CMake pour éviter les avertissements
# avec les versions récentes de CMake.
cmake_policy(VERSION 3.14...3.25)

# Définissez les options de configuration de build
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
          CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
            STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
            "Debug" "Profile" "Release")
  endif()
endif()

# Définissez les paramètres pour le mode de build "Profile"
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Utilisez Unicode pour tous les projets
add_definitions(-DUNICODE -D_UNICODE)

# Paramètres de compilation qui doivent être appliqués à la plupart des cibles
#
# Soyez prudent lors de l'ajout de nouvelles options ici, car les plugins utilisent cette fonction
# par défaut. Dans la plupart des cas, vous devriez ajouter de nouvelles options à des cibles spécifiques
# au lieu de modifier cette fonction.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Règles de build pour la bibliothèque et les outils Flutter
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Build de l'application ; voir runner/CMakeLists.txt
add_subdirectory("runner")

# Règles de build générées pour les plugins, qui gèrent la construction des plugins
# et leur ajout à l'application
include(flutter/generated_plugins.cmake)

# === Installation ===
# Les fichiers de support sont copiés à côté de l'exécutable, afin qu'il puisse
# s'exécuter sur place. Cela est fait au lieu de créer un bundle séparé (comme sur Linux)
# pour que la construction et l'exécution depuis Visual Studio fonctionnent.
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")

# Faites de l'étape "install" la valeur par défaut, car elle est requise pour l'exécution
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
        COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
        COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
        COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
          DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
          COMPONENT Runtime)
endif()

# Copiez les ressources natives fournies par build.dart depuis tous les packages
set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}"
        DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
        COMPONENT Runtime)

# Recopiez entièrement le répertoire des assets à chaque build pour éviter d'avoir des fichiers
# obsolètes provenant d'une installation précédente
set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")
  " COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}"
        DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

# Installez la bibliothèque AOT uniquement pour les builds non-Debug
install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
        CONFIGURATIONS Profile;Release
        COMPONENT Runtime)