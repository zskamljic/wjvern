%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%ConstructorAndInstanceMethods = type { %ConstructorAndInstanceMethods_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%ConstructorAndInstanceMethods_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ConstructorAndInstanceMethods_vtable_data = global %ConstructorAndInstanceMethods_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"ConstructorAndInstanceMethods_<init>()V"(%ConstructorAndInstanceMethods* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ConstructorAndInstanceMethods**
  store %ConstructorAndInstanceMethods* %param.0, %ConstructorAndInstanceMethods** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 2
  %1 = load %ConstructorAndInstanceMethods*, %ConstructorAndInstanceMethods** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ConstructorAndInstanceMethods*, %ConstructorAndInstanceMethods** %local.0
  %3 = getelementptr inbounds %ConstructorAndInstanceMethods, %ConstructorAndInstanceMethods* %2, i32 0, i32 0
  store %ConstructorAndInstanceMethods_vtable_type* @ConstructorAndInstanceMethods_vtable_data, %ConstructorAndInstanceMethods_vtable_type** %3
  %4 = load %ConstructorAndInstanceMethods*, %ConstructorAndInstanceMethods** %local.0
  %5 = getelementptr inbounds %ConstructorAndInstanceMethods, %ConstructorAndInstanceMethods* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 3
  %6 = alloca %java_Array
  %7 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 0
  store i32 13, i32* %7
  %8 = alloca i8, i32 13
  %9 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  store ptr %8, ptr %9
  call void @llvm.memset.p0.i8(ptr %8, i8 0, i64 13, i1 false)
  %10 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 0
  store i8 67, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 1
  store i8 111, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 2
  store i8 110, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 3
  store i8 115, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 4
  store i8 116, ptr %24
  %25 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i8, ptr %26, i32 5
  store i8 114, ptr %27
  %28 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = getelementptr inbounds i8, ptr %29, i32 6
  store i8 117, ptr %30
  %31 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %32 = load ptr, ptr %31
  %33 = getelementptr inbounds i8, ptr %32, i32 7
  store i8 99, ptr %33
  %34 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %35 = load ptr, ptr %34
  %36 = getelementptr inbounds i8, ptr %35, i32 8
  store i8 116, ptr %36
  %37 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %38 = load ptr, ptr %37
  %39 = getelementptr inbounds i8, ptr %38, i32 9
  store i8 111, ptr %39
  %40 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %41 = load ptr, ptr %40
  %42 = getelementptr inbounds i8, ptr %41, i32 10
  store i8 114, ptr %42
  %43 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %44 = load ptr, ptr %43
  %45 = getelementptr inbounds i8, ptr %44, i32 11
  store i8 10, ptr %45
  %46 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %47 = load ptr, ptr %46
  %48 = getelementptr inbounds i8, ptr %47, i32 12
  store i8 0, ptr %48
  %49 = alloca %java_Array
  %50 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 0
  store i32 0, i32* %50
  %51 = alloca i32, i32 0
  %52 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  store ptr %51, ptr %52
  call void @llvm.memset.p0.i32(ptr %51, i8 0, i64 0, i1 false)
  %53 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %54 = load ptr, ptr %53
  %55 = call i32(i8*,...) @printf(i8* %54)
  ; Line 4
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"ConstructorAndInstanceMethods_method()V"(%ConstructorAndInstanceMethods* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ConstructorAndInstanceMethods**
  store %ConstructorAndInstanceMethods* %param.0, %ConstructorAndInstanceMethods** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 7
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
  ; Line 8
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"ConstructorAndInstanceMethods_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %ConstructorAndInstanceMethods
  call void @"ConstructorAndInstanceMethods_<init>()V"(%ConstructorAndInstanceMethods* %1)
  call void @"ConstructorAndInstanceMethods_method()V"(%ConstructorAndInstanceMethods* %1)
  ; Line 13
  ret i32 0
}

declare i32 @printf(%java_Array, ...) nounwind
