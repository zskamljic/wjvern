%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%InstanceFields_vtable_type = type {  }

%InstanceFields = type { %InstanceFields_vtable_type*, i32, float, double }

@InstanceFields_vtable_data = global %InstanceFields_vtable_type {
}

define void @"InstanceFields_<init>"(%InstanceFields* %this) {
label0:
  ; Line 6
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ; Line 7
  %0 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i64 0, i32 0
  store i32 1, i32* %0
  ; Line 8
  %1 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i64 0, i32 1
  store float 5.0, float* %1
  ; Line 9
  %2 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i64 0, i32 2
  store double 7.0, double* %2
  ; Line 10
  ret void
}

define i32 @main() {
  ; Line 13
  %1 = alloca %InstanceFields
  call void @"InstanceFields_<init>"(%InstanceFields* %1)
  %instance = bitcast %InstanceFields* %1 to %InstanceFields*
  br label %label0
label0:
  ; Line 14
  %2 = alloca [4 x i8]
  %3 = getelementptr inbounds [4 x i8], ptr %2, i64 0, i32 0
  store i8 37, ptr %3
  %4 = getelementptr inbounds [4 x i8], ptr %2, i64 0, i32 1
  store i8 100, ptr %4
  %5 = getelementptr inbounds [4 x i8], ptr %2, i64 0, i32 2
  store i8 10, ptr %5
  %6 = getelementptr inbounds [4 x i8], ptr %2, i64 0, i32 3
  store i8 0, ptr %6
  %7 = alloca [1 x i32]
  %8 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i64 0, i32 0
  %9 = load i32, i32* %8
  %10 = getelementptr inbounds [1 x i32], ptr %7, i64 0, i32 0
  store i32 %9, ptr %10
  %11 = getelementptr inbounds [1 x i32], ptr %7, i64 0, i32 0
  %12 = load i32, i32* %11
  %13 = call i32 @printf(ptr %2, i32 %12)
  ; Line 15
  %14 = alloca [4 x i8]
  %15 = getelementptr inbounds [4 x i8], ptr %14, i64 0, i32 0
  store i8 37, ptr %15
  %16 = getelementptr inbounds [4 x i8], ptr %14, i64 0, i32 1
  store i8 102, ptr %16
  %17 = getelementptr inbounds [4 x i8], ptr %14, i64 0, i32 2
  store i8 10, ptr %17
  %18 = getelementptr inbounds [4 x i8], ptr %14, i64 0, i32 3
  store i8 0, ptr %18
  %19 = alloca [1 x float]
  %20 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i64 0, i32 1
  %21 = load float, float* %20
  %22 = getelementptr inbounds [1 x float], ptr %19, i64 0, i32 0
  store float %21, ptr %22
  %23 = getelementptr inbounds [1 x float], ptr %19, i64 0, i32 0
  %24 = load float, float* %23
  %25 = fpext float %24 to double
  %26 = call i32 @printf(ptr %14, double %25)
  ; Line 16
  %27 = alloca [4 x i8]
  %28 = getelementptr inbounds [4 x i8], ptr %27, i64 0, i32 0
  store i8 37, ptr %28
  %29 = getelementptr inbounds [4 x i8], ptr %27, i64 0, i32 1
  store i8 102, ptr %29
  %30 = getelementptr inbounds [4 x i8], ptr %27, i64 0, i32 2
  store i8 10, ptr %30
  %31 = getelementptr inbounds [4 x i8], ptr %27, i64 0, i32 3
  store i8 0, ptr %31
  %32 = alloca [1 x double]
  %33 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i64 0, i32 2
  %34 = load double, double* %33
  %35 = getelementptr inbounds [1 x double], ptr %32, i64 0, i32 0
  store double %34, ptr %35
  %36 = getelementptr inbounds [1 x double], ptr %32, i64 0, i32 0
  %37 = load double, double* %36
  %38 = call i32 @printf(ptr %27, double %37)
  ; Line 17
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
