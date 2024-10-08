%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%ForEach = type { %ForEach_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%ForEach_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ForEach_vtable_data = global %ForEach_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 10, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"ForEach_<init>()V"(%ForEach* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ForEach**
  store %ForEach* %param.0, %ForEach** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %ForEach*, %ForEach** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ForEach*, %ForEach** %local.0
  %3 = getelementptr inbounds %ForEach, %ForEach* %2, i32 0, i32 0
  store %ForEach_vtable_type* @ForEach_vtable_data, %ForEach_vtable_type** %3
  %4 = load %ForEach*, %ForEach** %local.0
  %5 = getelementptr inbounds %ForEach, %ForEach* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"ForEach_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 3, i32* %2
  %3 = alloca i32, i32 3
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i32(ptr %3, i8 0, i64 12, i1 false)
  %local.0 = alloca ptr
  store %java_Array* %1, ptr %local.0
  br label %label2
label2:
  ; %array entered scope under name %local.0
  ; Line 5
  %5 = load %java_Array*, %java_Array** %local.0
  %local.1 = alloca ptr
  store %java_Array* %5, ptr %local.1
  %6 = load %java_Array*, %java_Array** %local.1
  %7 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 0
  %8 = load i32, ptr %7
  %local.2 = alloca ptr
  store i32 %8, ptr %local.2
  %local.3 = alloca ptr
  store i32 0, ptr %local.3
  br label %label4
label4:
  %9 = load i32, i32* %local.2
  %10 = load i32, i32* %local.3
  %11 = icmp sge i32 %10, %9
  br i1 %11, label %label5, label %label6
label6:
  %12 = load i32, i32* %local.3
  %13 = load %java_Array*, %java_Array** %local.1
  %14 = getelementptr inbounds %java_Array, %java_Array* %13, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i32, ptr %15, i32 %12
  %17 = load i32, ptr %16
  %local.4 = alloca ptr
  store i32 %17, ptr %local.4
  br label %label0
label0:
  ; %i entered scope under name %local.4
  ; Line 6
  %18 = load i32, i32* %local.4
  call void @"ForEach_print(I)V"(i32 %18)
  br label %label1
label1:
  ; %i exited scope under name %local.4
  ; Line 5
  %19 = load i32, i32* %local.3
  %20 = add i32 %19, 1
  store i32 %20, i32* %local.3
  br label %label4
label5:
  ; Line 9
  ret i32 0
label3:
  ; %array exited scope under name %local.0
  unreachable
}

define void @"ForEach_print(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %number entered scope under name %local.0
  ; Line 13
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
  %local.1 = alloca ptr
  store %java_Array* %1, ptr %local.1
  br label %label2
label2:
  ; %pattern entered scope under name %local.1
  ; Line 14
  %17 = load %java_Array*, %java_Array** %local.1
  %18 = alloca %java_Array
  %19 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 0
  store i32 1, i32* %19
  %20 = alloca i32, i32 1
  %21 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  store ptr %20, ptr %21
  call void @llvm.memset.p0.i32(ptr %20, i8 0, i64 4, i1 false)
  %22 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i32, ptr %23, i32 0
  %25 = load i32, i32* %local.0
  store i32 %25, ptr %24
  %26 = getelementptr inbounds %java_Array, ptr %18, i32 0, i32 1
  %27 = load ptr, ptr %26
  %28 = getelementptr inbounds %java_Array, ptr %27, i32 0
  %29 = load i32, i32* %28
  %30 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %31 = load ptr, ptr %30
  %32 = call i32(i8*,...) @printf(i8* %31, i32 %29)
  ; Line 15
  ret void
label1:
  ; %number exited scope under name %local.0
  ; %pattern exited scope under name %local.1
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
