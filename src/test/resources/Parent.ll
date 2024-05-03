%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%Parent_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Parent*)* }

%Parent = type { %Parent_vtable_type*, i32, i32 }

define void @Parent_parentMethod(%Parent* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 6
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 1
  store i32 5, i32* %0
  ; Line 7
  ret void
}

define void @Parent_dynamic(%Parent* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 10
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 2
  store i32 3, i32* %0
  ; Line 11
  ret void
}

declare i32 @__gxx_personality_v0(...)

@Parent_vtable_data = global %Parent_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize",
  void(%Parent*)* @Parent_parentMethod,
  void(%Parent*)* @Parent_dynamic
}

define void @"Parent_<init>"(%Parent* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %0
  ret void
}
