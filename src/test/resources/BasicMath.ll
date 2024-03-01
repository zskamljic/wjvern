%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%BasicMath_vtable_type = type { }

%BasicMath = type { %BasicMath_vtable_type* }

@BasicMath_vtable_data = global %BasicMath_vtable_type {
}

define void @"BasicMath_<init>"(%BasicMath* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %BasicMath, %BasicMath* %this, i64 0, i32 0
  store %BasicMath_vtable_type* @BasicMath_vtable_data, %BasicMath_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 3
  %f = alloca float
  store float 1.0, ptr %f
  br label %label0
label0:
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
  %9 = alloca [4 x i8]
  %10 = getelementptr inbounds [4 x i8], ptr %9, i64 0, i32 0
  store i8 37, ptr %10
  %11 = getelementptr inbounds [4 x i8], ptr %9, i64 0, i32 1
  store i8 102, ptr %11
  %12 = getelementptr inbounds [4 x i8], ptr %9, i64 0, i32 2
  store i8 10, ptr %12
  %13 = getelementptr inbounds [4 x i8], ptr %9, i64 0, i32 3
  store i8 0, ptr %13
  %14 = alloca [1 x float]
  %15 = getelementptr inbounds [1 x float], ptr %14, i64 0, i32 0
  %16 = load float, float* %f
  store float %16, ptr %15
  %17 = getelementptr inbounds [1 x float], ptr %14, i64 0, i32 0
  %18 = load float, float* %17
  %19 = fpext float %18 to double
  %20 = call i32 @printf(ptr %9, double %19)
  ; Line 10
  %d = alloca double
  store double 1.0, ptr %d
  br label %label1
label1:
  ; Line 11
  %21 = load double, double* %d
  %22 = fadd double %21, 2.0
  store double %22, double* %d
  ; Line 12
  %23 = load double, double* %d
  %24 = fdiv double %23, 3.0
  store double %24, double* %d
  ; Line 13
  %25 = load double, double* %d
  %26 = fmul double %25, 4.0
  store double %26, double* %d
  ; Line 14
  %27 = load double, double* %d
  %28 = fsub double %27, 1.0
  store double %28, double* %d
  ; Line 15
  %29 = alloca [4 x i8]
  %30 = getelementptr inbounds [4 x i8], ptr %29, i64 0, i32 0
  store i8 37, ptr %30
  %31 = getelementptr inbounds [4 x i8], ptr %29, i64 0, i32 1
  store i8 102, ptr %31
  %32 = getelementptr inbounds [4 x i8], ptr %29, i64 0, i32 2
  store i8 10, ptr %32
  %33 = getelementptr inbounds [4 x i8], ptr %29, i64 0, i32 3
  store i8 0, ptr %33
  %34 = alloca [1 x double]
  %35 = getelementptr inbounds [1 x double], ptr %34, i64 0, i32 0
  %36 = load double, double* %d
  store double %36, ptr %35
  %37 = getelementptr inbounds [1 x double], ptr %34, i64 0, i32 0
  %38 = load double, double* %37
  %39 = call i32 @printf(ptr %29, double %38)
  ; Line 17
  %i = alloca i32
  store i32 1, ptr %i
  br label %label2
label2:
  ; Line 18
  %40 = load i32, i32* %i
  %41 = add i32 %40, 2
  store i32 %41, i32* %i
  ; Line 19
  %42 = load i32, i32* %i
  %43 = sdiv i32 %42, 3
  store i32 %43, i32* %i
  ; Line 20
  %44 = load i32, i32* %i
  %45 = mul i32 %44, 4
  store i32 %45, i32* %i
  ; Line 21
  %46 = load i32, i32* %i
  %47 = add i32 %46, -1
  store i32 %47, i32* %i
  ; Line 22
  %48 = load i32, ptr %i
  ret i32 %48
}

declare i32 @printf(ptr, ...) nounwind
