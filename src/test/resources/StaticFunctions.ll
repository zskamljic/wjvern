%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%StaticFunctions_vtable_type = type {  }

%StaticFunctions = type { %StaticFunctions_vtable_type* }

@StaticFunctions_vtable_data = global %StaticFunctions_vtable_type {
}

define void @"StaticFunctions_<init>"(%StaticFunctions* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ret void
}

define i32 @main() {
  ; Line 3
  %1 = call i32 @returnOne()
  ret i32 %1
}

define i32 @returnOne() {
  ; Line 7
  ret i32 1
}
