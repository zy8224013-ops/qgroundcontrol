# ============================================================================
# MARS GCS build configuration (QGC custom build mechanism)
# Rover-oriented simplified ground station for ArduPilot Rover.
# ============================================================================

# NOTE: QGC_APP_NAME becomes the CMake target name — no spaces allowed.
# The user-visible Android label ("MARS GCS") comes from custom/android/AndroidManifest.xml.
set(QGC_APP_NAME "MARSGCS" CACHE STRING "App Name" FORCE)
set(QGC_ANDROID_PACKAGE_NAME "com.yaoyou.marsgcs" CACHE STRING "Android package identifier" FORCE)
