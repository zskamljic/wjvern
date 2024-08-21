%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%FunctionOverloading = type { %FunctionOverloading_vtable_type* }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%FunctionOverloading_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%FunctionOverloading*)*, i32(%FunctionOverloading*, i32)* }

define i32 @"FunctionOverloading_doSomething()I"(%FunctionOverloading* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 3
  ret i32 1
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"FunctionOverloading_doSomething(I)I"(%FunctionOverloading* %local.0, i32 %local.1) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; %a entered scope under name %local.1
  ; Line 7
  ret i32 %local.1
label1:
  ; %this exited scope under name %local.0
  ; %a exited scope under name %local.1
  unreachable
}

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@FunctionOverloading_vtable_data = global %FunctionOverloading_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  i32(%FunctionOverloading*)* @"FunctionOverloading_doSomething()I",
  i32(%FunctionOverloading*, i32)* @"FunctionOverloading_doSomething(I)I"
}

define void @"FunctionOverloading_<init>()V"(%FunctionOverloading* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %local.0, i32 0, i32 0
  store %FunctionOverloading_vtable_type* @FunctionOverloading_vtable_data, %FunctionOverloading_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"FunctionOverloading_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %FunctionOverloading
  call void @"FunctionOverloading_<init>()V"(%FunctionOverloading* %1)
  %local.0 = alloca ptr
  store %FunctionOverloading* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 12
  %2 = load %FunctionOverloading*, %FunctionOverloading** %local.0
  %3 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %2, i32 0, i32 0
  %4 = load %FunctionOverloading_vtable_type*, %FunctionOverloading_vtable_type** %3
  %5 = getelementptr inbounds %FunctionOverloading_vtable_type, %FunctionOverloading_vtable_type* %4, i32 0, i32 3
  %6 = load i32(%FunctionOverloading*)*, i32(%FunctionOverloading*)** %5
  %7 = call i32 %6(%FunctionOverloading* %2)
  %8 = load %FunctionOverloading*, %FunctionOverloading** %local.0
  %9 = getelementptr inbounds %FunctionOverloading, %FunctionOverloading* %8, i32 0, i32 0
  %10 = load %FunctionOverloading_vtable_type*, %FunctionOverloading_vtable_type** %9
  %11 = getelementptr inbounds %FunctionOverloading_vtable_type, %FunctionOverloading_vtable_type* %10, i32 0, i32 4
  %12 = load i32(%FunctionOverloading*, i32)*, i32(%FunctionOverloading*, i32)** %11
  %13 = call i32 %12(%FunctionOverloading* %8, i32 2)
  %14 = add i32 %7, %13
  ret i32 %14
label1:
  ; %instance exited scope under name %local.0
  unreachable
}
