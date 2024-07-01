%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%FunctionOverloading_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%FunctionOverloading*)*, i32(%FunctionOverloading*, i32)* }

%FunctionOverloading = type { %FunctionOverloading_vtable_type* }

define i32 @"FunctionOverloading_doSomething()I"(%FunctionOverloading* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 3
  ret i32 1
}

define i32 @"FunctionOverloading_doSomething(I)I"(%FunctionOverloading* %this, i32 %a) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 7
  ret i32 %a
}

declare i32 @__gxx_personality_v0(...)

@FunctionOverloading_vtable_data = global %FunctionOverloading_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  i32(%FunctionOverloading*)* @"FunctionOverloading_doSomething()I",
  i32(%FunctionOverloading*, i32)* @"FunctionOverloading_doSomething(I)I"
}

define void @"FunctionOverloading_<init>()V"(%FunctionOverloading* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %this, i32 0, i32 0
  store %FunctionOverloading_vtable_type* @FunctionOverloading_vtable_data, %FunctionOverloading_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %FunctionOverloading
  call void @"FunctionOverloading_<init>()V"(%FunctionOverloading* %1)
  %local.0 = alloca ptr
  store %FunctionOverloading* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %FunctionOverloading*, ptr %local.0
  %instance = bitcast ptr %2 to %FunctionOverloading*
  ; Line 12
  %3 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %instance, i32 0, i32 0
  %4 = load %FunctionOverloading_vtable_type*, %FunctionOverloading_vtable_type** %3
  %5 = getelementptr inbounds %FunctionOverloading_vtable_type, %FunctionOverloading_vtable_type* %4, i32 0, i32 3
  %6 = load i32(%FunctionOverloading*)*, i32(%FunctionOverloading*)** %5
  %7 = call i32 %6(%FunctionOverloading* %instance)
  %8 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %instance, i32 0, i32 0
  %9 = load %FunctionOverloading_vtable_type*, %FunctionOverloading_vtable_type** %8
  %10 = getelementptr inbounds %FunctionOverloading_vtable_type, %FunctionOverloading_vtable_type* %9, i32 0, i32 4
  %11 = load i32(%FunctionOverloading*, i32)*, i32(%FunctionOverloading*, i32)** %10
  %12 = call i32 %11(%FunctionOverloading* %instance, i32 2)
  %13 = add i32 %7, %12
  ret i32 %13
}
