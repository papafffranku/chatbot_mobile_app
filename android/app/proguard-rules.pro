# Flutter
-keep class io.flutter.** { *; }
-keep class com.quantisage.travelassistant.** { *; }

# Play Core (fixes the missing classes error)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Multidex
-keep class androidx.multidex.** { *; }