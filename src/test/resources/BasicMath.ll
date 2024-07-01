%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%BasicMath_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%BasicMath = type { %BasicMath_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@BasicMath_vtable_data = global %BasicMath_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"BasicMath_<init>()V"(%BasicMath* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %BasicMath, %BasicMath* %this, i32 0, i32 0
  store %BasicMath_vtable_type* @BasicMath_vtable_data, %BasicMath_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store float 1.0, ptr %local.0
  br label %label0
label0:
  %f = bitcast ptr %local.0 to float*
  ; Line 4
  %1 = load float, float* %f
  %2 = fadd float %1, 2.0
  store float %2, float* %f
  ; Line 5
  %3 = load float, float* %f
  %4 = fdiv float %3, 3.0
  store float %4, float* %f
  ; Line 6
  %5 = load float, float* %f
  %6 = fmul float %5, 4.0
  store float %6, float* %f
  ; Line 7
  %7 = load float, float* %f
  %8 = fsub float %7, 1.0
  store float %8, float* %f
  ; Line 8
  %9 = alloca %java_Array
  %10 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 0
  store i32 4, i32* %10
  %11 = alloca i8, i32 4
  %12 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  store ptr %11, ptr %12
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
  %29 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  %30 = load ptr, ptr %29
  %31 = getelementptr inbounds float, ptr %30, i32 0
  %32 = load float, float* %f
  store float %32, ptr %31
  %33 = getelementptr inbounds %java_Array, ptr %25, i32 0, i32 1
  %34 = load ptr, ptr %33
  %35 = getelementptr inbounds %java_Array, ptr %34, i32 0
  %36 = load float, float* %35
  %37 = fpext float %36 to double
  %38 = getelementptr inbounds %java_Array, ptr %9, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = call i32 @printf(ptr %39, double %37)
  ; Line 10
  %local.1 = alloca ptr
  store double 1.0, ptr %local.1
  br label %label2
label2:
  %d = bitcast ptr %local.1 to double*
  ; Line 11
  %41 = load double, double* %d
  %42 = fadd double %41, 2.0
  store double %42, double* %d
  ; Line 12
  %43 = load double, double* %d
  %44 = fdiv double %43, 3.0
  store double %44, double* %d
  ; Line 13
  %45 = load double, double* %d
  %46 = fmul double %45, 4.0
  store double %46, double* %d
  ; Line 14
  %47 = load double, double* %d
  %48 = fsub double %47, 1.0
  store double %48, double* %d
  ; Line 15
  %49 = alloca %java_Array
  %50 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 0
  store i32 4, i32* %50
  %51 = alloca i8, i32 4
  %52 = getelementptr inbounds %java_Array, %java_Array* %49, i32 0, i32 1
  store ptr %51, ptr %52
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
  %69 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 1
  %70 = load ptr, ptr %69
  %71 = getelementptr inbounds double, ptr %70, i32 0
  %72 = load double, double* %d
  store double %72, ptr %71
  %73 = getelementptr inbounds %java_Array, ptr %65, i32 0, i32 1
  %74 = load ptr, ptr %73
  %75 = getelementptr inbounds %java_Array, ptr %74, i32 0
  %76 = load double, double* %75
  %77 = getelementptr inbounds %java_Array, ptr %49, i32 0, i32 1
  %78 = load ptr, ptr %77
  %79 = call i32 @printf(ptr %78, double %76)
  ; Line 17
  %local.3 = alloca ptr
  store i32 1, ptr %local.3
  br label %label3
label3:
  %i = bitcast ptr %local.3 to i32*
  ; Line 18
  %80 = load i32, i32* %i
  %81 = add i32 %80, 2
  store i32 %81, i32* %i
  ; Line 19
  %82 = load i32, i32* %i
  %83 = sdiv i32 %82, 3
  store i32 %83, i32* %i
  ; Line 20
  %84 = load i32, i32* %i
  %85 = mul i32 %84, 4
  store i32 %85, i32* %i
  ; Line 21
  %86 = load i32, i32* %i
  %87 = add i32 %86, -1
  store i32 %87, i32* %i
  ; Line 22
  %88 = load i32, i32* %i
  ret i32 %88
}

declare i32 @printf(%java_Array, ...) nounwind
