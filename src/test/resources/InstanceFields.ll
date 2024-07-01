%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%InstanceFields_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%InstanceFields = type { %InstanceFields_vtable_type*, i32, float, double }

declare i32 @__gxx_personality_v0(...)

@InstanceFields_vtable_data = global %InstanceFields_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"InstanceFields_<init>()V"(%InstanceFields* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 6
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i32 0, i32 0
  store %InstanceFields_vtable_type* @InstanceFields_vtable_data, %InstanceFields_vtable_type** %0
  ; Line 7
  %1 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i32 0, i32 1
  store i32 1, i32* %1
  ; Line 8
  %2 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i32 0, i32 2
  store float 5.0, float* %2
  ; Line 9
  %3 = getelementptr inbounds %InstanceFields, %InstanceFields* %this, i32 0, i32 3
  store double 7.0, double* %3
  ; Line 10
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = alloca %InstanceFields
  call void @"InstanceFields_<init>()V"(%InstanceFields* %1)
  %local.0 = alloca ptr
  store %InstanceFields* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %InstanceFields*, ptr %local.0
  %instance = bitcast ptr %2 to %InstanceFields*
  ; Line 14
  %3 = alloca %java_Array
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  store i32 4, i32* %4
  %5 = alloca i8, i32 4
  %6 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  store ptr %5, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 0
  store i8 37, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 1
  store i8 100, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 2
  store i8 10, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 3
  store i8 0, ptr %18
  %19 = alloca %java_Array
  %20 = getelementptr inbounds %java_Array, %java_Array* %19, i32 0, i32 0
  store i32 1, i32* %20
  %21 = alloca i32, i32 1
  %22 = getelementptr inbounds %java_Array, %java_Array* %19, i32 0, i32 1
  store ptr %21, ptr %22
  %23 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i32 0, i32 1
  %24 = load i32, i32* %23
  %25 = getelementptr inbounds %java_Array, %java_Array* %19, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i32, ptr %26, i32 0
  store i32 %24, ptr %27
  %28 = getelementptr inbounds %java_Array, ptr %19, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = getelementptr inbounds %java_Array, ptr %29, i32 0
  %31 = load i32, i32* %30
  %32 = getelementptr inbounds %java_Array, ptr %3, i32 0, i32 1
  %33 = load ptr, ptr %32
  %34 = call i32 @printf(ptr %33, i32 %31)
  ; Line 15
  %35 = alloca %java_Array
  %36 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 0
  store i32 4, i32* %36
  %37 = alloca i8, i32 4
  %38 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  store ptr %37, ptr %38
  %39 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  %40 = load ptr, ptr %39
  %41 = getelementptr inbounds i8, ptr %40, i32 0
  store i8 37, ptr %41
  %42 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  %43 = load ptr, ptr %42
  %44 = getelementptr inbounds i8, ptr %43, i32 1
  store i8 102, ptr %44
  %45 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  %46 = load ptr, ptr %45
  %47 = getelementptr inbounds i8, ptr %46, i32 2
  store i8 10, ptr %47
  %48 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  %49 = load ptr, ptr %48
  %50 = getelementptr inbounds i8, ptr %49, i32 3
  store i8 0, ptr %50
  %51 = alloca %java_Array
  %52 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 0
  store i32 1, i32* %52
  %53 = alloca float, i32 1
  %54 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 1
  store ptr %53, ptr %54
  %55 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i32 0, i32 2
  %56 = load float, float* %55
  %57 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 1
  %58 = load ptr, ptr %57
  %59 = getelementptr inbounds float, ptr %58, i32 0
  store float %56, ptr %59
  %60 = getelementptr inbounds %java_Array, ptr %51, i32 0, i32 1
  %61 = load ptr, ptr %60
  %62 = getelementptr inbounds %java_Array, ptr %61, i32 0
  %63 = load float, float* %62
  %64 = fpext float %63 to double
  %65 = getelementptr inbounds %java_Array, ptr %35, i32 0, i32 1
  %66 = load ptr, ptr %65
  %67 = call i32 @printf(ptr %66, double %64)
  ; Line 16
  %68 = alloca %java_Array
  %69 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 0
  store i32 4, i32* %69
  %70 = alloca i8, i32 4
  %71 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 1
  store ptr %70, ptr %71
  %72 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 1
  %73 = load ptr, ptr %72
  %74 = getelementptr inbounds i8, ptr %73, i32 0
  store i8 37, ptr %74
  %75 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 1
  %76 = load ptr, ptr %75
  %77 = getelementptr inbounds i8, ptr %76, i32 1
  store i8 102, ptr %77
  %78 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 1
  %79 = load ptr, ptr %78
  %80 = getelementptr inbounds i8, ptr %79, i32 2
  store i8 10, ptr %80
  %81 = getelementptr inbounds %java_Array, %java_Array* %68, i32 0, i32 1
  %82 = load ptr, ptr %81
  %83 = getelementptr inbounds i8, ptr %82, i32 3
  store i8 0, ptr %83
  %84 = alloca %java_Array
  %85 = getelementptr inbounds %java_Array, %java_Array* %84, i32 0, i32 0
  store i32 1, i32* %85
  %86 = alloca double, i32 1
  %87 = getelementptr inbounds %java_Array, %java_Array* %84, i32 0, i32 1
  store ptr %86, ptr %87
  %88 = getelementptr inbounds %InstanceFields, %InstanceFields* %instance, i32 0, i32 3
  %89 = load double, double* %88
  %90 = getelementptr inbounds %java_Array, %java_Array* %84, i32 0, i32 1
  %91 = load ptr, ptr %90
  %92 = getelementptr inbounds double, ptr %91, i32 0
  store double %89, ptr %92
  %93 = getelementptr inbounds %java_Array, ptr %84, i32 0, i32 1
  %94 = load ptr, ptr %93
  %95 = getelementptr inbounds %java_Array, ptr %94, i32 0
  %96 = load double, double* %95
  %97 = getelementptr inbounds %java_Array, ptr %68, i32 0, i32 1
  %98 = load ptr, ptr %97
  %99 = call i32 @printf(ptr %98, double %96)
  ; Line 17
  ret i32 0
}

declare i32 @printf(%java_Array, ...) nounwind
