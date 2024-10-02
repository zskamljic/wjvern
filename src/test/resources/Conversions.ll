%"java/lang/Object" = type { ptr, ptr }
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%Conversions = type { %Conversions_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Conversions_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Conversions_vtable_data = global %Conversions_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 2, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"Conversions_<init>()V"(%Conversions* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Conversions**
  store %Conversions* %param.0, %Conversions** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Conversions*, %Conversions** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Conversions*, %Conversions** %local.0
  %3 = getelementptr inbounds %Conversions, %Conversions* %2, i32 0, i32 0
  store %Conversions_vtable_type* @Conversions_vtable_data, %Conversions_vtable_type** %3
  %4 = load %Conversions*, %Conversions** %local.0
  %5 = getelementptr inbounds %Conversions, %Conversions* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Conversions_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store double 1.0, ptr %local.0
  br label %label0
label0:
  ; %d entered scope under name %local.0
  ; Line 4
  %1 = load double, double* %local.0
  %2 = fptrunc double %1 to float
  %local.2 = alloca ptr
  store float %2, ptr %local.2
  br label %label2
label2:
  ; %d2f entered scope under name %local.2
  ; Line 5
  %3 = load float, float* %local.2
  %4 = fpext float %3 to double
  call void @"Conversions_printDouble(D)V"(double %4)
  ; Line 6
  %5 = load double, double* %local.0
  %6 = fptosi double %5 to i32
  %local.3 = alloca ptr
  store i32 %6, ptr %local.3
  br label %label3
label3:
  ; %d2i entered scope under name %local.3
  ; Line 7
  %7 = load i32, i32* %local.3
  call void @"Conversions_printInt(I)V"(i32 %7)
  ; Line 8
  %8 = load double, double* %local.0
  %9 = fptosi double %8 to i64
  %local.4 = alloca ptr
  store i64 %9, ptr %local.4
  br label %label4
label4:
  ; %d2l entered scope under name %local.4
  ; Line 9
  %10 = load i64, i64* %local.4
  call void @"Conversions_printLong(J)V"(i64 %10)
  ; Line 11
  %11 = load float, float* %local.2
  %12 = fpext float %11 to double
  %local.6 = alloca ptr
  store double %12, ptr %local.6
  br label %label5
label5:
  ; %f2d entered scope under name %local.6
  ; Line 12
  %13 = load double, double* %local.6
  call void @"Conversions_printDouble(D)V"(double %13)
  ; Line 13
  %14 = load float, float* %local.2
  %15 = fptosi float %14 to i32
  %local.8 = alloca ptr
  store i32 %15, ptr %local.8
  br label %label6
label6:
  ; %f2i entered scope under name %local.8
  ; Line 14
  %16 = load i32, i32* %local.8
  call void @"Conversions_printInt(I)V"(i32 %16)
  ; Line 15
  %17 = load float, float* %local.2
  %18 = fptosi float %17 to i64
  %local.9 = alloca ptr
  store i64 %18, ptr %local.9
  br label %label7
label7:
  ; %f2l entered scope under name %local.9
  ; Line 16
  %19 = load i64, i64* %local.9
  call void @"Conversions_printLong(J)V"(i64 %19)
  ; Line 18
  %20 = load i32, i32* %local.3
  %21 = trunc i32 %20 to i8
  %local.11 = alloca ptr
  store i8 %21, ptr %local.11
  br label %label8
label8:
  ; %i2b entered scope under name %local.11
  ; Line 19
  %22 = load i8, i8* %local.11
  call void @"Conversions_printInt(I)V"(i8 %22)
  ; Line 20
  %23 = load i32, i32* %local.3
  %24 = trunc i32 %23 to i16
  %local.12 = alloca ptr
  store i16 %24, ptr %local.12
  br label %label9
label9:
  ; %i2c entered scope under name %local.12
  ; Line 21
  %25 = load i16, i16* %local.12
  call void @"Conversions_printInt(I)V"(i16 %25)
  ; Line 22
  %26 = load i32, i32* %local.3
  %27 = sitofp i32 %26 to double
  %local.13 = alloca ptr
  store double %27, ptr %local.13
  br label %label10
label10:
  ; %i2d entered scope under name %local.13
  ; Line 23
  %28 = load double, double* %local.13
  call void @"Conversions_printDouble(D)V"(double %28)
  ; Line 24
  %29 = load i32, i32* %local.3
  %30 = sitofp i32 %29 to float
  %local.15 = alloca ptr
  store float %30, ptr %local.15
  br label %label11
label11:
  ; %i2f entered scope under name %local.15
  ; Line 25
  %31 = load float, float* %local.15
  %32 = fpext float %31 to double
  call void @"Conversions_printDouble(D)V"(double %32)
  ; Line 26
  %33 = load i32, i32* %local.3
  %34 = sext i32 %33 to i64
  %local.16 = alloca ptr
  store i64 %34, ptr %local.16
  br label %label12
label12:
  ; %i2l entered scope under name %local.16
  ; Line 27
  %35 = load i64, i64* %local.16
  call void @"Conversions_printLong(J)V"(i64 %35)
  ; Line 28
  %36 = load i32, i32* %local.3
  %37 = trunc i32 %36 to i16
  %local.18 = alloca ptr
  store i16 %37, ptr %local.18
  br label %label13
label13:
  ; %i2s entered scope under name %local.18
  ; Line 29
  %38 = load i16, i16* %local.18
  call void @"Conversions_printInt(I)V"(i16 %38)
  ; Line 31
  %39 = load i64, i64* %local.4
  %40 = sitofp i64 %39 to double
  %local.19 = alloca ptr
  store double %40, ptr %local.19
  br label %label14
label14:
  ; %l2d entered scope under name %local.19
  ; Line 32
  %41 = load double, double* %local.19
  call void @"Conversions_printDouble(D)V"(double %41)
  ; Line 33
  %42 = load i64, i64* %local.4
  %43 = sitofp i64 %42 to float
  %local.21 = alloca ptr
  store float %43, ptr %local.21
  br label %label15
label15:
  ; %l2f entered scope under name %local.21
  ; Line 34
  %44 = load float, float* %local.21
  %45 = fpext float %44 to double
  call void @"Conversions_printDouble(D)V"(double %45)
  ; Line 35
  %46 = load i64, i64* %local.4
  %47 = trunc i64 %46 to i32
  %local.22 = alloca ptr
  store i32 %47, ptr %local.22
  br label %label16
label16:
  ; %l2i entered scope under name %local.22
  ; Line 36
  %48 = load i32, i32* %local.22
  call void @"Conversions_printInt(I)V"(i32 %48)
  ; Line 38
  ret i32 0
label1:
  ; %d exited scope under name %local.0
  ; %d2f exited scope under name %local.2
  ; %d2i exited scope under name %local.3
  ; %d2l exited scope under name %local.4
  ; %f2d exited scope under name %local.6
  ; %f2i exited scope under name %local.8
  ; %f2l exited scope under name %local.9
  ; %i2b exited scope under name %local.11
  ; %i2c exited scope under name %local.12
  ; %i2d exited scope under name %local.13
  ; %i2f exited scope under name %local.15
  ; %i2l exited scope under name %local.16
  ; %i2s exited scope under name %local.18
  ; %l2d exited scope under name %local.19
  ; %l2f exited scope under name %local.21
  ; %l2i exited scope under name %local.22
  unreachable
}

define void @"Conversions_printInt(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 42
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
  ; %intPattern entered scope under name %local.1
  ; Line 43
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
  ; Line 44
  ret void
label1:
  ; %value exited scope under name %local.0
  ; %intPattern exited scope under name %local.1
  unreachable
}

define void @"Conversions_printLong(J)V"(i64 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i64*
  store i64 %param.0, i64* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 47
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 5, i32* %2
  %3 = alloca i8, i32 5
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 5, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 37, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 108, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 100, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 10, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 4
  store i8 0, ptr %19
  %local.2 = alloca ptr
  store %java_Array* %1, ptr %local.2
  br label %label2
label2:
  ; %longPattern entered scope under name %local.2
  ; Line 48
  %20 = load %java_Array*, %java_Array** %local.2
  %21 = alloca %java_Array
  %22 = getelementptr inbounds %java_Array, %java_Array* %21, i32 0, i32 0
  store i32 1, i32* %22
  %23 = alloca i64, i32 1
  %24 = getelementptr inbounds %java_Array, %java_Array* %21, i32 0, i32 1
  store ptr %23, ptr %24
  call void @llvm.memset.p0.i64(ptr %23, i8 0, i64 8, i1 false)
  %25 = getelementptr inbounds %java_Array, %java_Array* %21, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i64, ptr %26, i32 0
  %28 = load i64, i64* %local.0
  store i64 %28, ptr %27
  %29 = getelementptr inbounds %java_Array, ptr %21, i32 0, i32 1
  %30 = load ptr, ptr %29
  %31 = getelementptr inbounds %java_Array, ptr %30, i32 0
  %32 = load i64, i64* %31
  %33 = getelementptr inbounds %java_Array, %java_Array* %20, i32 0, i32 1
  %34 = load ptr, ptr %33
  %35 = call i32(i8*,...) @printf(i8* %34, i64 %32)
  ; Line 49
  ret void
label1:
  ; %value exited scope under name %local.0
  ; %longPattern exited scope under name %local.2
  unreachable
}

define void @"Conversions_printDouble(D)V"(double %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca double*
  store double %param.0, double* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 52
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
  store i8 102, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 10, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 0, ptr %16
  %local.2 = alloca ptr
  store %java_Array* %1, ptr %local.2
  br label %label2
label2:
  ; %doublePattern entered scope under name %local.2
  ; Line 53
  %17 = load %java_Array*, %java_Array** %local.2
  %18 = alloca %java_Array
  %19 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 0
  store i32 1, i32* %19
  %20 = alloca double, i32 1
  %21 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  store ptr %20, ptr %21
  call void @llvm.memset.p0.i64(ptr %20, i8 0, i64 4, i1 false)
  %22 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds double, ptr %23, i32 0
  %25 = load double, double* %local.0
  store double %25, ptr %24
  %26 = getelementptr inbounds %java_Array, ptr %18, i32 0, i32 1
  %27 = load ptr, ptr %26
  %28 = getelementptr inbounds %java_Array, ptr %27, i32 0
  %29 = load double, double* %28
  %30 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %31 = load ptr, ptr %30
  %32 = call i32(i8*,...) @printf(i8* %31, double %29)
  ; Line 54
  ret void
label1:
  ; %value exited scope under name %local.0
  ; %doublePattern exited scope under name %local.2
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
