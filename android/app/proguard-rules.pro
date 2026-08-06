# Keep SLF4J classes
-keep class org.slf4j.** { *; }
-keep interface org.slf4j.** { *; }
-dontwarn org.slf4j.**

# Keep StaticLoggerBinder specifically
-keep class org.slf4j.impl.StaticLoggerBinder { *; }
-dontwarn org.slf4j.impl.StaticLoggerBinder

# General logging framework rules
-dontwarn java.util.logging.**
-dontwarn org.apache.log4j.**
-dontwarn org.apache.commons.logging.**