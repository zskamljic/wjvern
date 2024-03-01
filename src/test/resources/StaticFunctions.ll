%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%StaticFunctions_vtable_type = type { }

%StaticFunctions = type { %StaticFunctions_vtable_type* }

@StaticFunctions_vtable_data = global %StaticFunctions_vtable_type {
}

define void @"StaticFunctions_<init>"(%StaticFunctions* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %StaticFunctions, %StaticFunctions* %this, i64 0, i32 0
  store %StaticFunctions_vtable_type* @StaticFunctions_vtable_data, %StaticFunctions_vtable_type** %0
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
