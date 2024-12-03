%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%VirtualMethods = type { %VirtualMethods_vtable_type*, %java_TypeInfo*, i32 }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object"*)
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%VirtualMethods_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, void(%VirtualMethods*)* }
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)* }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@VirtualMethods_vtable_data = global %VirtualMethods_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object"*)* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  void(%VirtualMethods*)* @"VirtualMethods_doSomething()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"VirtualMethods_<init>()V"(%VirtualMethods* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %VirtualMethods**
  store %VirtualMethods* %param.0, %VirtualMethods** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %VirtualMethods*, %VirtualMethods** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %VirtualMethods*, %VirtualMethods** %local.0
  %3 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %2, i32 0, i32 0
  store %VirtualMethods_vtable_type* @VirtualMethods_vtable_data, %VirtualMethods_vtable_type** %3
  %4 = load %VirtualMethods*, %VirtualMethods** %local.0
  %5 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"VirtualMethods_doSomething()V"(%VirtualMethods* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %VirtualMethods**
  store %VirtualMethods* %param.0, %VirtualMethods** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 4
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 8, i32* %2
  %3 = alloca i8, i32 8
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 8, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 109, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 101, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 116, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 104, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 4
  store i8 111, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i8, ptr %21, i32 5
  store i8 100, ptr %22
  %23 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds i8, ptr %24, i32 6
  store i8 10, ptr %25
  %26 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %27 = load ptr, ptr %26
  %28 = getelementptr inbounds i8, ptr %27, i32 7
  store i8 0, ptr %28
  %29 = alloca %java_Array
  %30 = getelementptr inbounds %java_Array, %java_Array* %29, i32 0, i32 0
  store i32 0, i32* %30
  %31 = alloca i32, i32 0
  %32 = getelementptr inbounds %java_Array, %java_Array* %29, i32 0, i32 1
  store ptr %31, ptr %32
  call void @llvm.memset.p0.i32(ptr %31, i8 0, i64 0, i1 false)
  %33 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %34 = load ptr, ptr %33
  %35 = call i32(i8*,...) @printf(i8* %34)
  ; Line 5
  %36 = load %VirtualMethods*, %VirtualMethods** %local.0
  %37 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %36, i32 0, i32 2
  store i32 5, i32* %37
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"VirtualMethods_main()I"() personality ptr @__gxx_personality_v0 {
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
  %8 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %7, i32 0, i32 2
  %9 = load i32, i32* %8
  ret i32 %9
label1:
  ; %instance exited scope under name %local.0
  unreachable
}

declare i32 @printf(ptr, ...) nounwind
