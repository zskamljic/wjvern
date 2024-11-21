%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%ReferenceFields = type { %ReferenceFields_vtable_type*, %java_TypeInfo*, %java_Array*, %ReferenceFields* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%ReferenceFields_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ReferenceFields_vtable_data = global %ReferenceFields_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 12, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"ReferenceFields_<init>()V"(%ReferenceFields* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ReferenceFields**
  store %ReferenceFields* %param.0, %ReferenceFields** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %ReferenceFields*, %ReferenceFields** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ReferenceFields*, %ReferenceFields** %local.0
  %3 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %2, i32 0, i32 0
  store %ReferenceFields_vtable_type* @ReferenceFields_vtable_data, %ReferenceFields_vtable_type** %3
  %4 = load %ReferenceFields*, %ReferenceFields** %local.0
  %5 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"ReferenceFields_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 6
  %1 = alloca %ReferenceFields
  call void @"ReferenceFields_<init>()V"(%ReferenceFields* %1)
  %local.0 = alloca ptr
  store %ReferenceFields* %1, ptr %local.0
  br label %label0
label0:
  ; %refs entered scope under name %local.0
  ; Line 7
  %2 = load %ReferenceFields*, %ReferenceFields** %local.0
  %3 = alloca %java_Array
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  store i32 2, i32* %4
  %5 = alloca i32, i32 2
  %6 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  store ptr %5, ptr %6
  call void @llvm.memset.p0.i32(ptr %5, i8 0, i64 8, i1 false)
  %7 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i32, ptr %8, i32 0
  store i32 1, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i32, ptr %11, i32 1
  store i32 2, ptr %12
  %13 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %2, i32 0, i32 2
  store %java_Array* %3, %java_Array** %13
  ; Line 8
  %14 = load %ReferenceFields*, %ReferenceFields** %local.0
  %15 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %14, i32 0, i32 2
  %16 = load %java_Array*, %java_Array** %15
  %17 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i32, ptr %18, i32 0
  %20 = load i32, ptr %19
  call void @"ReferenceFields_printInt(I)V"(i32 %20)
  ; Line 9
  %21 = load %ReferenceFields*, %ReferenceFields** %local.0
  %22 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %21, i32 0, i32 2
  %23 = load %java_Array*, %java_Array** %22
  %24 = getelementptr inbounds %java_Array, %java_Array* %23, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = getelementptr inbounds i32, ptr %25, i32 1
  %27 = load i32, ptr %26
  call void @"ReferenceFields_printInt(I)V"(i32 %27)
  ; Line 11
  %28 = load %ReferenceFields*, %ReferenceFields** %local.0
  %29 = alloca %ReferenceFields
  call void @"ReferenceFields_<init>()V"(%ReferenceFields* %29)
  %30 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %28, i32 0, i32 3
  store %ReferenceFields* %29, %ReferenceFields** %30
  ; Line 12
  %31 = load %ReferenceFields*, %ReferenceFields** %local.0
  %32 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %31, i32 0, i32 3
  %33 = load %ReferenceFields*, %ReferenceFields** %32
  %34 = alloca %java_Array
  %35 = getelementptr inbounds %java_Array, %java_Array* %34, i32 0, i32 0
  store i32 2, i32* %35
  %36 = alloca i32, i32 2
  %37 = getelementptr inbounds %java_Array, %java_Array* %34, i32 0, i32 1
  store ptr %36, ptr %37
  call void @llvm.memset.p0.i32(ptr %36, i8 0, i64 8, i1 false)
  %38 = getelementptr inbounds %java_Array, %java_Array* %34, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = getelementptr inbounds i32, ptr %39, i32 0
  store i32 3, ptr %40
  %41 = getelementptr inbounds %java_Array, %java_Array* %34, i32 0, i32 1
  %42 = load ptr, ptr %41
  %43 = getelementptr inbounds i32, ptr %42, i32 1
  store i32 4, ptr %43
  %44 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %33, i32 0, i32 2
  store %java_Array* %34, %java_Array** %44
  ; Line 13
  %45 = load %ReferenceFields*, %ReferenceFields** %local.0
  %46 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %45, i32 0, i32 3
  %47 = load %ReferenceFields*, %ReferenceFields** %46
  %48 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %47, i32 0, i32 2
  %49 = load %java_Array*, %java_Array** %48
  %50 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %51 = load ptr, ptr %50
  %52 = getelementptr inbounds i32, ptr %51, i32 0
  %53 = load i32, ptr %52
  call void @"ReferenceFields_printInt(I)V"(i32 %53)
  ; Line 14
  %54 = load %ReferenceFields*, %ReferenceFields** %local.0
  %55 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %54, i32 0, i32 3
  %56 = load %ReferenceFields*, %ReferenceFields** %55
  %57 = getelementptr inbounds %ReferenceFields, %ReferenceFields* %56, i32 0, i32 2
  %58 = load %java_Array*, %java_Array** %57
  %59 = getelementptr inbounds %java_Array, %java_Array* %58, i32 0, i32 1
  %60 = load ptr, ptr %59
  %61 = getelementptr inbounds i32, ptr %60, i32 1
  %62 = load i32, ptr %61
  call void @"ReferenceFields_printInt(I)V"(i32 %62)
  ; Line 16
  ret i32 0
label1:
  ; %refs exited scope under name %local.0
  unreachable
}

define void @"ReferenceFields_printInt(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %i entered scope under name %local.0
  ; Line 20
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 4, i32* %2
  %3 = alloca i8, i32 4
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 4, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 37, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 100, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 10, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 0, ptr %16
  %17 = alloca %java_Array
  %18 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 0
  store i32 1, i32* %18
  %19 = alloca i32, i32 1
  %20 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  store ptr %19, ptr %20
  call void @llvm.memset.p0.i32(ptr %19, i8 0, i64 4, i1 false)
  %21 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i32, ptr %22, i32 0
  %24 = load i32, i32* %local.0
  store i32 %24, ptr %23
  %25 = getelementptr inbounds %java_Array, ptr %17, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds %java_Array, ptr %26, i32 0
  %28 = load i32, i32* %27
  %29 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %30 = load ptr, ptr %29
  %31 = call i32(i8*,...) @printf(i8* %30, i32 %28)
  ; Line 21
  ret void
label1:
  ; %i exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
