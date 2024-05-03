%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%StaticFunctions_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%StaticFunctions = type { %StaticFunctions_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@StaticFunctions_vtable_data = global %StaticFunctions_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"StaticFunctions_<init>"(%StaticFunctions* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %StaticFunctions, %StaticFunctions* %this, i64 0, i32 0
  store %StaticFunctions_vtable_type* @StaticFunctions_vtable_data, %StaticFunctions_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = call i32 @returnOne()
  ret i32 %1
}

define i32 @returnOne() personality ptr @__gxx_personality_v0 {
  ; Line 7
  ret i32 1
}
