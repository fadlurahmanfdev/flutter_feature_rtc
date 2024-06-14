fvm use 3.22.2 \
  && fvm global 3.22.2 \
  && fvm flutter clean \
  && fvm flutter pub get \
  && fvm flutter pub run build_runner build --delete-conflicting-outputs