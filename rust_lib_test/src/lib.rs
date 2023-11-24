#[repr(C)]
pub struct MyStruct {
    index: usize,
    isolate_hash: isize,
}

#[no_mangle]
pub extern "C" fn create_my(index: usize, isolate_hash: isize) -> *const MyStruct {
    let m = MyStruct { index, isolate_hash };
    Box::into_raw(Box::new(m))
}

/// # Safety
/// - `ptr` should be from [`create`]
#[no_mangle]
pub unsafe extern "C" fn free_my(ptr: *const MyStruct) {
    let m = Box::from_raw(ptr.cast_mut());
    println!("rust: drop {:?} {} {}", ptr, m.index, m.isolate_hash);
    drop(m);
}

use std::ffi::c_void;
use dart_sys::{*};

/// # Safety
#[no_mangle]
pub unsafe extern "C" fn init_my(data: *mut c_void) -> bool {
    Dart_InitializeApiDL(data) == 0
}


#[repr(C)]
#[derive(Debug)]
struct _FinalizablePeer {
    callback: extern "C" fn(ptr: *mut c_void),
    ptr: *mut c_void,
}


/// # Safety
#[no_mangle]
pub unsafe extern "C" fn set_finalizable(
    capability: Dart_Handle,
    ptr: *mut c_void,
    external_allocation_size: isize,
    callback: extern "C" fn(ptr: *mut c_void),
) {
    unsafe extern "C" fn _callback(_isolate_callback_data: *mut c_void, peer: *mut c_void) {
        let peer = Box::from_raw(peer as *mut _FinalizablePeer);
        (peer.callback)(peer.ptr);
        drop(peer);
    }

    let peer = Box::new(_FinalizablePeer { callback, ptr });

    let _ = Dart_NewFinalizableHandle_DL.unwrap()
        (capability, Box::into_raw(peer) as *mut c_void, external_allocation_size, Some(_callback));
}
