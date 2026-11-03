# =======================
# Flutter / Dart default rules
# =======================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# =======================
# Stripe SDK rules
# =======================
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
-keepattributes *Annotation*

# =======================
# Razorpay SDK rules
# =======================
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*

# =======================
# React Native Stripe bridge (sometimes used indirectly)
# =======================
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**
