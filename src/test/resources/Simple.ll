%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%Simple_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Simple = type { %Simple_vtable_type* }

@Simple_vtable_data = global %Simple_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"Simple_<init>"(%Simple* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Simple, %Simple* %this, i64 0, i32 0
  store %Simple_vtable_type* @Simple_vtable_data, %Simple_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 3
  ret i32 0
}
