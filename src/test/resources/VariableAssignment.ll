%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%VariableAssignment_vtable_type = type { }

%VariableAssignment = type { %VariableAssignment_vtable_type* }

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
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
  store i32 1, ptr %i
  br label %label1
label1:
  ; Line 11
  %2 = load i32, ptr %i
  ret i32 %2
}
