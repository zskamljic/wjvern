%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%Parameters_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Parameters = type { %Parameters_vtable_type* }

@Parameters_vtable_data = global %Parameters_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"Parameters_<init>"(%Parameters* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Parameters, %Parameters* %this, i64 0, i32 0
  store %Parameters_vtable_type* @Parameters_vtable_data, %Parameters_vtable_type** %0
  ret void
}

define i32 @Parameters_something(%Parameters* %this, i32 %a) {
label0:
  ; Line 3
  ret i32 %a
}

define i32 @main() {
  ; Line 7
  %1 = alloca %Parameters
  call void @"Parameters_<init>"(%Parameters* %1)
  %instance = bitcast %Parameters* %1 to %Parameters*
  br label %label0
label0:
  ; Line 8
  %2 = call i32 @"Parameters_something"(%Parameters* %instance, i32 5)
  ret i32 %2
}
