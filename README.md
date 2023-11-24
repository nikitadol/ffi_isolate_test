
## macOS

```shell
git clone git@github.com:nikitadol/ffi_isolate_test.git
cd ffi_isolate_test
dart pub get
cd rust_lib_test
cargo build
cd ..
dart --enable-vm-service:3000 lib/main.dart
```
