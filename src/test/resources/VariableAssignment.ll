%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%VariableAssignment_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%VariableAssignment = type { %VariableAssignment_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"VariableAssignment_<init>()V"(%VariableAssignment* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %this, i64 0, i32 0
  store %VariableAssignment_vtable_type* @VariableAssignment_vtable_data, %VariableAssignment_vtable_type** %0
  ret void
}

define void @"VariableAssignment_method()V"(%VariableAssignment* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 4
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 7
  %1 = alloca %VariableAssignment
  call void @"VariableAssignment_<init>()V"(%VariableAssignment* %1)
  %local.0 = alloca ptr
  store %VariableAssignment* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %VariableAssignment*, ptr %local.0
  %instance = bitcast ptr %2 to %VariableAssignment*
  ; Line 8
  call void @"VariableAssignment_method()V"(%VariableAssignment* %instance)
  ; Line 10
  %local.1 = alloca ptr
  store i32 1, ptr %local.1
  br label %label2
label2:
  %i = bitcast ptr %local.1 to i32*
  ; Line 11
  %3 = load i32, i32* %i
  ret i32 %3
}
