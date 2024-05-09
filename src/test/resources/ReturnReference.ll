%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%ReturnReference_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%ReturnReference*)* }

%ReturnReference = type { %ReturnReference_vtable_type* }

define i32 @"ReturnReference_returnValue()I"(%ReturnReference* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 3
  ret i32 4
}

declare i32 @__gxx_personality_v0(...)

@ReturnReference_vtable_data = global %ReturnReference_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  i32(%ReturnReference*)* @"ReturnReference_returnValue()I"
}

define void @"ReturnReference_<init>()V"(%ReturnReference* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %ReturnReference, %ReturnReference* %this, i64 0, i32 0
  store %ReturnReference_vtable_type* @ReturnReference_vtable_data, %ReturnReference_vtable_type** %0
  ret void
}

define void @createInstance(ptr sret(%ReturnReference) %0) personality ptr @__gxx_personality_v0 {
  ; Line 7
  %2 = alloca %ReturnReference
  call void @"ReturnReference_<init>()V"(%ReturnReference* %2)
  %3 = load %ReturnReference, %ReturnReference* %2
  store %ReturnReference %3, %ReturnReference* %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %ReturnReference
  call void @createInstance(ptr sret(%ReturnReference) %1)
  %local.0 = alloca ptr
  store %ReturnReference* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %ReturnReference*, ptr %local.0
  %instance = bitcast ptr %2 to %ReturnReference*
  ; Line 12
  %3 = getelementptr inbounds %ReturnReference, %ReturnReference* %instance, i64 0, i32 0
  %4 = load %ReturnReference_vtable_type*, %ReturnReference_vtable_type** %3
  %5 = getelementptr inbounds %ReturnReference_vtable_type, %ReturnReference_vtable_type* %4, i64 0, i32 2
  %6 = load i32(%ReturnReference*)*, i32(%ReturnReference*)** %5
  %7 = call i32 %6(%ReturnReference* %instance)
  ret i32 %7
}
