%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%VariableAssignment_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%VariableAssignment = type { %VariableAssignment_vtable_type* }

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"VariableAssignment_<init>"(%VariableAssignment* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %this, i64 0, i32 0
  store %VariableAssignment_vtable_type* @VariableAssignment_vtable_data, %VariableAssignment_vtable_type** %0
  ret void
}

define void @VariableAssignment_method(%VariableAssignment* %this) {
label0:
  ; Line 4
  ret void
}

define i32 @main() {
  ; Line 7
  %1 = alloca %VariableAssignment
  call void @"VariableAssignment_<init>"(%VariableAssignment* %1)
  %instance = bitcast %VariableAssignment* %1 to %VariableAssignment*
  br label %label0
label0:
  ; Line 8
  call void @"VariableAssignment_method"(%VariableAssignment* %instance)
  ; Line 10
  %i = alloca i32
  store i32 1, i32* %i
  br label %label1
label1:
  ; Line 11
  %2 = load i32, i32* %i
  ret i32 %2
}
