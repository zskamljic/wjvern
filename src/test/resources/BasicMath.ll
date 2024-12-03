%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%BasicMath = type { %BasicMath_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object"*)
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%BasicMath_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)* }
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

@BasicMath_vtable_data = global %BasicMath_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object"*)* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"BasicMath_<init>()V"(%BasicMath* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %BasicMath**
  store %BasicMath* %param.0, %BasicMath** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %BasicMath*, %BasicMath** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %BasicMath*, %BasicMath** %local.0
  %3 = getelementptr inbounds %BasicMath, %BasicMath* %2, i32 0, i32 0
  store %BasicMath_vtable_type* @BasicMath_vtable_data, %BasicMath_vtable_type** %3
  %4 = load %BasicMath*, %BasicMath** %local.0
  %5 = getelementptr inbounds %BasicMath, %BasicMath* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"BasicMath_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store float 1.0, ptr %local.0
  br label %label0
label0:
  ; %f entered scope under name %local.0
  ; Line 4
  %1 = load float, float* %local.0
  %2 = fadd float %1, 2.0
  store float %2, float* %local.0
  ; Line 5
  %3 = load float, float* %local.0
  %4 = fdiv float %3, 3.0
  store float %4, float* %local.0
  ; Line 6
  %5 = load float, float* %local.0
  %6 = fmul float %5, 4.0
  store float %6, float* %local.0
  ; Line 7
  %7 = load float, float* %local.0
  %8 = fsub float %7, 1.0
  store float %8, float* %local.0
  ; Line 8
  %9 = alloca %java_Array
  %10 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 0
  store i32 4, i32* %10
  %11 = alloca i8, i32 4
  %12 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  store ptr %11, ptr %12
  call void @llvm.memset.p0.i8(ptr %11, i8 0, i64 4, i1 false)
  %13 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 0
  store i8 37, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 1
  store i8 102, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 2
  store i8 10, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 3
  store i8 0, ptr %24
  %25 = alloca %java_Array
  %26 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 0
  store i32 1, i32* %26
  %27 = alloca float, i32 1
  %28 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  store ptr %27, ptr %28
  call void @llvm.memset.p0.i32(ptr %27, i8 0, i64 4, i1 false)
  %29 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  %30 = load ptr, ptr %29
  %31 = getelementptr inbounds float, ptr %30, i32 0
  %32 = load float, float* %local.0
  store float %32, ptr %31
  %33 = getelementptr inbounds %java_Array, ptr %25, i32 0, i32 1
  %34 = load ptr, ptr %33
  %35 = getelementptr inbounds %java_Array, ptr %34, i32 0
  %36 = load float, float* %35
  %37 = fpext float %36 to double
  %38 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = call i32(i8*,...) @printf(i8* %39, double %37)
  ; Line 10
  %local.1 = alloca ptr
  store double 1.0, ptr %local.1
  br label %label2
label2:
  ; %d entered scope under name %local.1
  ; Line 11
  %41 = load double, double* %local.1
  %42 = fadd double %41, 2.0
  store double %42, double* %local.1
  ; Line 12
  %43 = load double, double* %local.1
  %44 = fdiv double %43, 3.0
  store double %44, double* %local.1
  ; Line 13
  %45 = load double, double* %local.1
  %46 = fmul double %45, 4.0
  store double %46, double* %local.1
  ; Line 14
  %47 = load double, double* %local.1
  %48 = fsub double %47, 1.0
  store double %48, double* %local.1
  ; Line 15
  %49 = alloca %java_Array
  %50 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 0
  store i32 4, i32* %50
  %51 = alloca i8, i32 4
  %52 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  store ptr %51, ptr %52
  call void @llvm.memset.p0.i8(ptr %51, i8 0, i64 4, i1 false)
  %53 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %54 = load ptr, ptr %53
  %55 = getelementptr inbounds i8, ptr %54, i32 0
  store i8 37, ptr %55
  %56 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %57 = load ptr, ptr %56
  %58 = getelementptr inbounds i8, ptr %57, i32 1
  store i8 102, ptr %58
  %59 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %60 = load ptr, ptr %59
  %61 = getelementptr inbounds i8, ptr %60, i32 2
  store i8 10, ptr %61
  %62 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %63 = load ptr, ptr %62
  %64 = getelementptr inbounds i8, ptr %63, i32 3
  store i8 0, ptr %64
  %65 = alloca %java_Array
  %66 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 0
  store i32 1, i32* %66
  %67 = alloca double, i32 1
  %68 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 1
  store ptr %67, ptr %68
  call void @llvm.memset.p0.i64(ptr %67, i8 0, i64 4, i1 false)
  %69 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 1
  %70 = load ptr, ptr %69
  %71 = getelementptr inbounds double, ptr %70, i32 0
  %72 = load double, double* %local.1
  store double %72, ptr %71
  %73 = getelementptr inbounds %java_Array, ptr %65, i32 0, i32 1
  %74 = load ptr, ptr %73
  %75 = getelementptr inbounds %java_Array, ptr %74, i32 0
  %76 = load double, double* %75
  %77 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  %78 = load ptr, ptr %77
  %79 = call i32(i8*,...) @printf(i8* %78, double %76)
  ; Line 17
  %local.3 = alloca ptr
  store i32 1, ptr %local.3
  br label %label3
label3:
  ; %i entered scope under name %local.3
  ; Line 18
  %80 = load i32, i32* %local.3
  %81 = add i32 %80, 2
  store i32 %81, i32* %local.3
  ; Line 19
  %82 = load i32, i32* %local.3
  %83 = sdiv i32 %82, 3
  store i32 %83, i32* %local.3
  ; Line 20
  %84 = load i32, i32* %local.3
  %85 = mul i32 %84, 4
  store i32 %85, i32* %local.3
  ; Line 21
  %86 = load i32, i32* %local.3
  %87 = add i32 %86, -1
  store i32 %87, i32* %local.3
  ; Line 22
  %88 = load i32, i32* %local.3
  ret i32 %88
label1:
  ; %f exited scope under name %local.0
  ; %d exited scope under name %local.1
  ; %i exited scope under name %local.3
  unreachable
}

declare i32 @printf(ptr, ...) nounwind
