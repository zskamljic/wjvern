%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%NativeVarArgMethods = type { }

define void @"NativeVarArgMethods_<init>"(%NativeVarArgMethods* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ret void
}

define i32 @main() {
  ; Line 3
  %1 = alloca [4 x i8]
  %2 = getelementptr inbounds [4 x i8], ptr %1, i64 0, i32 0
  store i8 37, ptr %2
  %3 = getelementptr inbounds [4 x i8], ptr %1, i64 0, i32 1
  store i8 100, ptr %3
  %4 = getelementptr inbounds [4 x i8], ptr %1, i64 0, i32 2
  store i8 10, ptr %4
  %5 = getelementptr inbounds [4 x i8], ptr %1, i64 0, i32 3
  store i8 0, ptr %5
  %6 = alloca [1 x i32]
  %7 = getelementptr inbounds [1 x i32], ptr %6, i64 0, i32 0
  store i32 1, ptr %7
  %8 = getelementptr inbounds [1 x i32], ptr %6, i64 0, i32 0
  %9 = load i32, i32* %8
  %10 = call i32 @printf(ptr %1, i32 %9)
  ; Line 4
  %11 = alloca [4 x i8]
  %12 = getelementptr inbounds [4 x i8], ptr %11, i64 0, i32 0
  store i8 37, ptr %12
  %13 = getelementptr inbounds [4 x i8], ptr %11, i64 0, i32 1
  store i8 102, ptr %13
  %14 = getelementptr inbounds [4 x i8], ptr %11, i64 0, i32 2
  store i8 10, ptr %14
  %15 = getelementptr inbounds [4 x i8], ptr %11, i64 0, i32 3
  store i8 0, ptr %15
  %16 = alloca [1 x float]
  %17 = getelementptr inbounds [1 x float], ptr %16, i64 0, i32 0
  store float 2.0, ptr %17
  %18 = getelementptr inbounds [1 x float], ptr %16, i64 0, i32 0
  %19 = load float, float* %18
  %20 = fpext float %19 to double
  %21 = call i32 @printf(ptr %11, double %20)
  ; Line 5
  %22 = alloca [4 x i8]
  %23 = getelementptr inbounds [4 x i8], ptr %22, i64 0, i32 0
  store i8 37, ptr %23
  %24 = getelementptr inbounds [4 x i8], ptr %22, i64 0, i32 1
  store i8 102, ptr %24
  %25 = getelementptr inbounds [4 x i8], ptr %22, i64 0, i32 2
  store i8 10, ptr %25
  %26 = getelementptr inbounds [4 x i8], ptr %22, i64 0, i32 3
  store i8 0, ptr %26
  %27 = alloca [1 x double]
  %28 = getelementptr inbounds [1 x double], ptr %27, i64 0, i32 0
  store double 3.0, ptr %28
  %29 = getelementptr inbounds [1 x double], ptr %27, i64 0, i32 0
  %30 = load double, double* %29
  %31 = call i32 @printf(ptr %22, double %30)
  ; Line 6
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind