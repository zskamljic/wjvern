%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%VariableAssignment_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%VariableAssignment = type { %VariableAssignment_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"VariableAssignment_<init>()V"(%VariableAssignment* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %local.0, i32 0, i32 0
  store %VariableAssignment_vtable_type* @VariableAssignment_vtable_data, %VariableAssignment_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"VariableAssignment_method()V"(%VariableAssignment* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 4
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 7
  %1 = alloca %VariableAssignment
  call void @"VariableAssignment_<init>()V"(%VariableAssignment* %1)
  %local.0 = alloca ptr
  store %VariableAssignment* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 8
  %2 = load %VariableAssignment*, %VariableAssignment** %local.0
  call void @"VariableAssignment_method()V"(%VariableAssignment* %2)
  ; Line 10
  %local.1 = alloca ptr
  store i32 1, ptr %local.1
  br label %label2
label2:
  ; %i entered scope under name %local.1
  ; Line 11
  %3 = load i32, i32* %local.1
  ret i32 %3
label1:
  ; %instance exited scope under name %local.0
  ; %i exited scope under name %local.1
  unreachable
}
