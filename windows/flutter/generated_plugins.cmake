#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  cloud_firestore
  firebase_auth
  firebase_core
<<<<<<< HEAD
  permission_handler_windows
=======
  flutter_secure_storage_windows
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
  share_plus
  url_launcher_windows
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
<<<<<<< HEAD
=======
  flutter_local_notifications_windows
>>>>>>> e7105b1f419548c2d80209a9eca410177f0a8a53
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
