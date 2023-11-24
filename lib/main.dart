import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi_isolate_test/generated_bindings.dart';

final dynamicLib = DynamicLibrary.open(
  "rust_lib_test/target/debug/librust_lib_test.dylib",
);
final lib = NativeLibrary(dynamicLib)..init_my(NativeApi.initializeApiDLData);

Future<void> main() async {
  print('init: ${lib.init_my(NativeApi.initializeApiDLData)}');

  print("isolateHash: ${Isolate.current.hashCode}");

  print(MyClass(0));
  print(MyClass(1));
  _createGarbage();

  await _isolateTest(MyClass(2));
  _createGarbage();

  await Future.delayed(Duration(seconds: 100));
}

Future<void> _isolateTest(MyClass myOther) async {
  final my = await Isolate.run(() {
    print(myOther);
    final my = MyClass(3);
    print(my);
    return my;
  });

  print(my);
}

int _createGarbage() {
  int cum = 0;
  for (var i = 1; i < 1000; ++i) {
    final l = List.filled(5000, 42);
    cum += l[l.length - i];
  }
  return cum;
}

abstract class SharedPointer<T extends NativeType> {
  final int _ptr;
  final Capability _capability = Capability();

  SharedPointer(
    Pointer<T> pointer,
    int externalAllocationSize,
    Pointer<NativeFunction<Void Function(Pointer<Void> ptr)>> callback,
  ) : _ptr = pointer.address {
    lib.set_finalizable(
      _capability,
      pointer.cast(),
      externalAllocationSize,
      callback,
    );
  }

  Pointer<T> get pointer => Pointer<T>.fromAddress(_ptr);
}

class MyClass extends SharedPointer<MyStruct> {
  factory MyClass(int index) {
    return MyClass._(lib.create_my(index, Isolate.current.hashCode));
  }

  MyClass._(Pointer<MyStruct> pointer)
      : super(pointer, sizeOf<MyStruct>(), lib.free_myPtr.cast());

  @override
  String toString() {
    return 'MyClass { pointer: $pointer index: ${pointer.ref.index} isolateHash: ${pointer.ref.isolate_hash} }';
  }
}
