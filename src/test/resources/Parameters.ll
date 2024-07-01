%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%Parameters_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Parameters = type { %Parameters_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@Parameters_vtable_data = global %Parameters_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Parameters_<init>()V"(%Parameters* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Parameters, %Parameters* %this, i32 0, i32 0
  store %Parameters_vtable_type* @Parameters_vtable_data, %Parameters_vtable_type** %0
  ret void
}

define i32 @"Parameters_something(I)I"(%Parameters* %this, i32 %a) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 3
  ret i32 %a
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 7
  %1 = alloca %Parameters
  call void @"Parameters_<init>()V"(%Parameters* %1)
  %local.0 = alloca ptr
  store %Parameters* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %Parameters*, ptr %local.0
  %instance = bitcast ptr %2 to %Parameters*
  ; Line 8
  %3 = call i32 @"Parameters_something(I)I"(%Parameters* %instance, i32 5)
  ret i32 %3
}
