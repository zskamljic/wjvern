%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%ConstructorAndInstanceMethods = type { %ConstructorAndInstanceMethods_vtable_type* }
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%ConstructorAndInstanceMethods_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ConstructorAndInstanceMethods_vtable_data = global %ConstructorAndInstanceMethods_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

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
  ; Line 3
  %4 = alloca %java_Array
  %5 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 0
  store i32 13, i32* %5
  %6 = alloca i8, i32 13
  %7 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  store ptr %6, ptr %7
  call void @llvm.memset.p0.i8(ptr %6, i8 0, i64 13, i1 false)
  %8 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 0
  store i8 67, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 1
  store i8 111, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 2
  store i8 110, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 3
  store i8 115, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i8, ptr %21, i32 4
  store i8 116, ptr %22
  %23 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds i8, ptr %24, i32 5
  store i8 114, ptr %25
  %26 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %27 = load ptr, ptr %26
  %28 = getelementptr inbounds i8, ptr %27, i32 6
  store i8 117, ptr %28
  %29 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %30 = load ptr, ptr %29
  %31 = getelementptr inbounds i8, ptr %30, i32 7
  store i8 99, ptr %31
  %32 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %33 = load ptr, ptr %32
  %34 = getelementptr inbounds i8, ptr %33, i32 8
  store i8 116, ptr %34
  %35 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %36 = load ptr, ptr %35
  %37 = getelementptr inbounds i8, ptr %36, i32 9
  store i8 111, ptr %37
  %38 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = getelementptr inbounds i8, ptr %39, i32 10
  store i8 114, ptr %40
  %41 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %42 = load ptr, ptr %41
  %43 = getelementptr inbounds i8, ptr %42, i32 11
  store i8 10, ptr %43
  %44 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %45 = load ptr, ptr %44
  %46 = getelementptr inbounds i8, ptr %45, i32 12
  store i8 0, ptr %46
  %47 = alloca %java_Array
  %48 = getelementptr inbounds %java_Array, %java_Array* %47, i32 0, i32 0
  store i32 0, i32* %48
  %49 = alloca i32, i32 0
  %50 = getelementptr inbounds %java_Array, %java_Array* %47, i32 0, i32 1
  store ptr %49, ptr %50
  call void @llvm.memset.p0.i32(ptr %49, i8 0, i64 0, i1 false)
  %51 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %52 = load ptr, ptr %51
  %53 = call i32(i8*,...) @printf(i8* %52)
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
