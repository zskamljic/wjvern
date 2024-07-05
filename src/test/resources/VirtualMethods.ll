%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%VirtualMethods_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%VirtualMethods*)* }

%VirtualMethods = type { %VirtualMethods_vtable_type*, i32 }

define void @"VirtualMethods_doSomething()V"(%VirtualMethods* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 4
  %0 = alloca %java_Array
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  store i32 8, i32* %1
  %2 = alloca i8, i32 8
  %3 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  store ptr %2, ptr %3
  call void @llvm.memset.p0.i8(ptr %2, i8 0, i64 8, i1 false)
  %4 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %5 = load ptr, ptr %4
  %6 = getelementptr inbounds i8, ptr %5, i32 0
  store i8 109, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 1
  store i8 101, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 2
  store i8 116, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 3
  store i8 104, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 4
  store i8 111, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 5
  store i8 100, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 6
  store i8 10, ptr %24
  %25 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i8, ptr %26, i32 7
  store i8 0, ptr %27
  %28 = alloca %java_Array
  %29 = getelementptr inbounds %java_Array, %java_Array* %28, i32 0, i32 0
  store i32 0, i32* %29
  %30 = alloca i32, i32 0
  %31 = getelementptr inbounds %java_Array, %java_Array* %28, i32 0, i32 1
  store ptr %30, ptr %31
  call void @llvm.memset.p0.i32(ptr %30, i8 0, i64 0, i1 false)
  %32 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %33 = load ptr, ptr %32
  %34 = call i32(i8*,...) @printf(i8* %33)
  ; Line 5
  %35 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %local.0, i32 0, i32 1
  store i32 5, i32* %35
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@VirtualMethods_vtable_data = global %VirtualMethods_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  void(%VirtualMethods*)* @"VirtualMethods_doSomething()V"
}

define void @"VirtualMethods_<init>()V"(%VirtualMethods* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %local.0, i32 0, i32 0
  store %VirtualMethods_vtable_type* @VirtualMethods_vtable_data, %VirtualMethods_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 9
  %1 = alloca %VirtualMethods
  call void @"VirtualMethods_<init>()V"(%VirtualMethods* %1)
  %local.0 = alloca ptr
  store %VirtualMethods* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 10
  %2 = load %VirtualMethods*, %VirtualMethods** %local.0
  %3 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %2, i32 0, i32 0
  %4 = load %VirtualMethods_vtable_type*, %VirtualMethods_vtable_type** %3
  %5 = getelementptr inbounds %VirtualMethods_vtable_type, %VirtualMethods_vtable_type* %4, i32 0, i32 3
  %6 = load void(%VirtualMethods*)*, void(%VirtualMethods*)** %5
  call void %6(%VirtualMethods* %2)
  ; Line 11
  %7 = load %VirtualMethods*, %VirtualMethods** %local.0
  %8 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %7, i32 0, i32 1
  %9 = load i32, i32* %8
  ret i32 %9
label1:
  ; %instance exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
