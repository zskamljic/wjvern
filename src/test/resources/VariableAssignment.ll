%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%VariableAssignment_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%VariableAssignment = type { %VariableAssignment_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"VariableAssignment_<init>"(%VariableAssignment* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %this, i64 0, i32 0
  store %VariableAssignment_vtable_type* @VariableAssignment_vtable_data, %VariableAssignment_vtable_type** %0
  ret void
}

define void @VariableAssignment_method(%VariableAssignment* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 4
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  %instance = alloca %VariableAssignment
  %i = alloca i32
  ; Line 7
  %1 = alloca %VariableAssignment
  call void @"VariableAssignment_<init>"(%VariableAssignment* %1)
  %2 = load %VariableAssignment, %VariableAssignment* %1
  store %VariableAssignment %2, %VariableAssignment* %instance
  br label %label0
label0:
  ; Line 8
  call void @"VariableAssignment_method"(%VariableAssignment* %instance)
  ; Line 10
  store i32 1, i32* %i
  br label %label1
label1:
  ; Line 11
  %3 = load i32, i32* %i
  ret i32 %3
}
