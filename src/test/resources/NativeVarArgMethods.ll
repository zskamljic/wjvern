%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%NativeVarArgMethods_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%NativeVarArgMethods = type { %NativeVarArgMethods_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@NativeVarArgMethods_vtable_data = global %NativeVarArgMethods_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"NativeVarArgMethods_<init>()V"(%NativeVarArgMethods* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %NativeVarArgMethods, %NativeVarArgMethods* %local.0, i32 0, i32 0
  store %NativeVarArgMethods_vtable_type* @NativeVarArgMethods_vtable_data, %NativeVarArgMethods_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 4, i32* %2
  %3 = alloca i8, i32 4
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
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
  %21 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i32, ptr %22, i32 0
  store i32 1, ptr %23
  %24 = getelementptr inbounds %java_Array, ptr %17, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = getelementptr inbounds %java_Array, ptr %25, i32 0
  %27 = load i32, i32* %26
  %28 = getelementptr inbounds %java_Array, ptr %1, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = call i32 @printf(ptr %29, i32 %27)
  ; Line 4
  %31 = alloca %java_Array
  %32 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 0
  store i32 4, i32* %32
  %33 = alloca i8, i32 4
  %34 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  store ptr %33, ptr %34
  %35 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  %36 = load ptr, ptr %35
  %37 = getelementptr inbounds i8, ptr %36, i32 0
  store i8 37, ptr %37
  %38 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = getelementptr inbounds i8, ptr %39, i32 1
  store i8 102, ptr %40
  %41 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  %42 = load ptr, ptr %41
  %43 = getelementptr inbounds i8, ptr %42, i32 2
  store i8 10, ptr %43
  %44 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  %45 = load ptr, ptr %44
  %46 = getelementptr inbounds i8, ptr %45, i32 3
  store i8 0, ptr %46
  %47 = alloca %java_Array
  %48 = getelementptr inbounds %java_Array, %java_Array* %47, i32 0, i32 0
  store i32 1, i32* %48
  %49 = alloca float, i32 1
  %50 = getelementptr inbounds %java_Array, %java_Array* %47, i32 0, i32 1
  store ptr %49, ptr %50
  %51 = getelementptr inbounds %java_Array, %java_Array* %47, i32 0, i32 1
  %52 = load ptr, ptr %51
  %53 = getelementptr inbounds float, ptr %52, i32 0
  store float 2.0, ptr %53
  %54 = getelementptr inbounds %java_Array, ptr %47, i32 0, i32 1
  %55 = load ptr, ptr %54
  %56 = getelementptr inbounds %java_Array, ptr %55, i32 0
  %57 = load float, float* %56
  %58 = fpext float %57 to double
  %59 = getelementptr inbounds %java_Array, ptr %31, i32 0, i32 1
  %60 = load ptr, ptr %59
  %61 = call i32 @printf(ptr %60, double %58)
  ; Line 5
  %62 = alloca %java_Array
  %63 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 0
  store i32 4, i32* %63
  %64 = alloca i8, i32 4
  %65 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 1
  store ptr %64, ptr %65
  %66 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 1
  %67 = load ptr, ptr %66
  %68 = getelementptr inbounds i8, ptr %67, i32 0
  store i8 37, ptr %68
  %69 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 1
  %70 = load ptr, ptr %69
  %71 = getelementptr inbounds i8, ptr %70, i32 1
  store i8 102, ptr %71
  %72 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 1
  %73 = load ptr, ptr %72
  %74 = getelementptr inbounds i8, ptr %73, i32 2
  store i8 10, ptr %74
  %75 = getelementptr inbounds %java_Array, %java_Array* %62, i32 0, i32 1
  %76 = load ptr, ptr %75
  %77 = getelementptr inbounds i8, ptr %76, i32 3
  store i8 0, ptr %77
  %78 = alloca %java_Array
  %79 = getelementptr inbounds %java_Array, %java_Array* %78, i32 0, i32 0
  store i32 1, i32* %79
  %80 = alloca double, i32 1
  %81 = getelementptr inbounds %java_Array, %java_Array* %78, i32 0, i32 1
  store ptr %80, ptr %81
  %82 = getelementptr inbounds %java_Array, %java_Array* %78, i32 0, i32 1
  %83 = load ptr, ptr %82
  %84 = getelementptr inbounds double, ptr %83, i32 0
  store double 3.0, ptr %84
  %85 = getelementptr inbounds %java_Array, ptr %78, i32 0, i32 1
  %86 = load ptr, ptr %85
  %87 = getelementptr inbounds %java_Array, ptr %86, i32 0
  %88 = load double, double* %87
  %89 = getelementptr inbounds %java_Array, ptr %62, i32 0, i32 1
  %90 = load ptr, ptr %89
  %91 = call i32 @printf(ptr %90, double %88)
  ; Line 6
  ret i32 0
}

declare i32 @printf(%java_Array, ...) nounwind
