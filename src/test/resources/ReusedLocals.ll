%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%ReusedLocals = type { %ReusedLocals_vtable_type*, %java_TypeInfo*, i32 }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%ReusedLocals_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ReusedLocals_vtable_data = global %ReusedLocals_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 9, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"ReusedLocals_<init>(I)V"(%ReusedLocals* %param.0, i32 %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ReusedLocals**
  store %ReusedLocals* %param.0, %ReusedLocals** %local.0
  %local.1 = alloca i32*
  store i32 %param.1, i32* %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %x entered scope under name %local.1
  ; Line 4
  %1 = load %ReusedLocals*, %ReusedLocals** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ReusedLocals*, %ReusedLocals** %local.0
  %3 = getelementptr inbounds %ReusedLocals, %ReusedLocals* %2, i32 0, i32 0
  store %ReusedLocals_vtable_type* @ReusedLocals_vtable_data, %ReusedLocals_vtable_type** %3
  %4 = load %ReusedLocals*, %ReusedLocals** %local.0
  %5 = getelementptr inbounds %ReusedLocals, %ReusedLocals* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 5
  %6 = load %ReusedLocals*, %ReusedLocals** %local.0
  %7 = load i32, i32* %local.1
  %8 = getelementptr inbounds %ReusedLocals, %ReusedLocals* %6, i32 0, i32 2
  store i32 %7, i32* %8
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %x exited scope under name %local.1
  unreachable
}

define i32 @"ReusedLocals_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 9
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 3, i32* %2
  %3 = alloca i32, i32 3
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i32(ptr %3, i8 0, i64 12, i1 false)
  %local.0 = alloca ptr
  store %java_Array* %1, ptr %local.0
  br label %label6
label6:
  ; %intArray entered scope under name %local.0
  ; Line 11
  %local.1 = alloca ptr
  store i32 0, ptr %local.1
  br label %label0
label0:
  ; %i entered scope under name %local.1
  %5 = load %java_Array*, %java_Array** %local.0
  %6 = getelementptr inbounds %java_Array, %java_Array* %5, i32 0, i32 0
  %7 = load i32, ptr %6
  %8 = load i32, i32* %local.1
  %9 = icmp sge i32 %8, %7
  br i1 %9, label %label1, label %label9
label9:
  ; Line 12
  %10 = load %java_Array*, %java_Array** %local.0
  %11 = getelementptr inbounds %java_Array, %java_Array* %10, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = load i32, i32* %local.1
  %14 = getelementptr inbounds i32, ptr %12, i32 %13
  %15 = load i32, i32* %local.1
  store i32 %15, ptr %14
  ; Line 11
  %16 = load i32, i32* %local.1
  %17 = add i32 %16, 1
  store i32 %17, i32* %local.1
  br label %label0
label1:
  ; %i exited scope under name %local.1
  ; Line 15
  %18 = alloca %java_Array
  %19 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 0
  store i32 3, i32* %19
  %20 = alloca %ReusedLocals, i32 3
  %21 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  store ptr %20, ptr %21
  store %java_Array* %18, ptr %local.1
  br label %label8
label8:
  ; %array entered scope under name %local.1
  ; Line 17
  %local.2 = alloca ptr
  store i32 0, ptr %local.2
  br label %label2
label2:
  ; %i entered scope under name %local.2
  %22 = load %java_Array*, %java_Array** %local.1
  %23 = getelementptr inbounds %java_Array, %java_Array* %22, i32 0, i32 0
  %24 = load i32, ptr %23
  %25 = load i32, i32* %local.2
  %26 = icmp sge i32 %25, %24
  br i1 %26, label %label3, label %label10
label10:
  ; Line 18
  %27 = load %java_Array*, %java_Array** %local.1
  %28 = alloca %ReusedLocals
  %29 = load i32, i32* %local.2
  call void @"ReusedLocals_<init>(I)V"(%ReusedLocals* %28, i32 %29)
  %30 = getelementptr inbounds %java_Array, %java_Array* %27, i32 0, i32 1
  %31 = load ptr, ptr %30
  %32 = load i32, i32* %local.2
  %33 = getelementptr inbounds %ReusedLocals, ptr %31, i32 %32
  store %ReusedLocals* %28, ptr %33
  ; Line 17
  %34 = load i32, i32* %local.2
  %35 = add i32 %34, 1
  store i32 %35, i32* %local.2
  br label %label2
label3:
  ; %i exited scope under name %local.2
  ; Line 21
  store i32 0, ptr %local.2
  br label %label4
label4:
  ; %i entered scope under name %local.2
  %36 = load %java_Array*, %java_Array** %local.1
  %37 = getelementptr inbounds %java_Array, %java_Array* %36, i32 0, i32 0
  %38 = load i32, ptr %37
  %39 = load i32, i32* %local.2
  %40 = icmp sge i32 %39, %38
  br i1 %40, label %label5, label %label11
label11:
  ; Line 22
  %41 = load %java_Array*, %java_Array** %local.1
  %42 = load i32, i32* %local.2
  %43 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %44 = load ptr, ptr %43
  %45 = getelementptr inbounds %ReusedLocals, ptr %44, i32 %42
  %46 = load %ReusedLocals*, ptr %45
  %47 = getelementptr inbounds %ReusedLocals, %ReusedLocals* %46, i32 0, i32 2
  %48 = load i32, i32* %47
  call void @"ReusedLocals_print(I)V"(i32 %48)
  ; Line 21
  %49 = load i32, i32* %local.2
  %50 = add i32 %49, 1
  store i32 %50, i32* %local.2
  br label %label4
label5:
  ; %i exited scope under name %local.2
  ; Line 24
  ret i32 0
label7:
  ; %intArray exited scope under name %local.0
  ; %array exited scope under name %local.1
  unreachable
}

define void @"ReusedLocals_print(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %number entered scope under name %local.0
  ; Line 28
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
  ; Line 29
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
  ; Line 30
  ret void
label1:
  ; %number exited scope under name %local.0
  ; %pattern exited scope under name %local.1
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
