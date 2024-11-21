%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%InstanceFields = type { %InstanceFields_vtable_type*, %java_TypeInfo*, i32, float, double }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%InstanceFields_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@InstanceFields_vtable_data = global %InstanceFields_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 12, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"InstanceFields_<init>()V"(%InstanceFields* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %InstanceFields**
  store %InstanceFields* %param.0, %InstanceFields** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 6
  %1 = load %InstanceFields*, %InstanceFields** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %InstanceFields*, %InstanceFields** %local.0
  %3 = getelementptr inbounds %InstanceFields, %InstanceFields* %2, i32 0, i32 0
  store %InstanceFields_vtable_type* @InstanceFields_vtable_data, %InstanceFields_vtable_type** %3
  %4 = load %InstanceFields*, %InstanceFields** %local.0
  %5 = getelementptr inbounds %InstanceFields, %InstanceFields* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 7
  %6 = load %InstanceFields*, %InstanceFields** %local.0
  %7 = getelementptr inbounds %InstanceFields, %InstanceFields* %6, i32 0, i32 2
  store i32 1, i32* %7
  ; Line 8
  %8 = load %InstanceFields*, %InstanceFields** %local.0
  %9 = getelementptr inbounds %InstanceFields, %InstanceFields* %8, i32 0, i32 3
  store float 5.0, float* %9
  ; Line 9
  %10 = load %InstanceFields*, %InstanceFields** %local.0
  %11 = getelementptr inbounds %InstanceFields, %InstanceFields* %10, i32 0, i32 4
  store double 7.0, double* %11
  ; Line 10
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"InstanceFields_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = alloca %InstanceFields
  call void @"InstanceFields_<init>()V"(%InstanceFields* %1)
  %local.0 = alloca ptr
  store %InstanceFields* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 14
  %2 = alloca %java_Array
  %3 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 0
  store i32 4, i32* %3
  %4 = alloca i8, i32 4
  %5 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  store ptr %4, ptr %5
  call void @llvm.memset.p0.i8(ptr %4, i8 0, i64 4, i1 false)
  %6 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %7 = load ptr, ptr %6
  %8 = getelementptr inbounds i8, ptr %7, i32 0
  store i8 37, ptr %8
  %9 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %10 = load ptr, ptr %9
  %11 = getelementptr inbounds i8, ptr %10, i32 1
  store i8 100, ptr %11
  %12 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %13 = load ptr, ptr %12
  %14 = getelementptr inbounds i8, ptr %13, i32 2
  store i8 10, ptr %14
  %15 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %16 = load ptr, ptr %15
  %17 = getelementptr inbounds i8, ptr %16, i32 3
  store i8 0, ptr %17
  %18 = alloca %java_Array
  %19 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 0
  store i32 1, i32* %19
  %20 = alloca i32, i32 1
  %21 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  store ptr %20, ptr %21
  call void @llvm.memset.p0.i32(ptr %20, i8 0, i64 4, i1 false)
  %22 = load %InstanceFields*, %InstanceFields** %local.0
  %23 = getelementptr inbounds %InstanceFields, %InstanceFields* %22, i32 0, i32 2
  %24 = load i32, i32* %23
  %25 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i32, ptr %26, i32 0
  store i32 %24, ptr %27
  %28 = getelementptr inbounds %java_Array, ptr %18, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = getelementptr inbounds %java_Array, ptr %29, i32 0
  %31 = load i32, i32* %30
  %32 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %33 = load ptr, ptr %32
  %34 = call i32(i8*,...) @printf(i8* %33, i32 %31)
  ; Line 15
  %35 = alloca %java_Array
  %36 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 0
  store i32 4, i32* %36
  %37 = alloca i8, i32 4
  %38 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  store ptr %37, ptr %38
  call void @llvm.memset.p0.i8(ptr %37, i8 0, i64 4, i1 false)
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
  call void @llvm.memset.p0.i32(ptr %53, i8 0, i64 4, i1 false)
  %55 = load %InstanceFields*, %InstanceFields** %local.0
  %56 = getelementptr inbounds %InstanceFields, %InstanceFields* %55, i32 0, i32 3
  %57 = load float, float* %56
  %58 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 1
  %59 = load ptr, ptr %58
  %60 = getelementptr inbounds float, ptr %59, i32 0
  store float %57, ptr %60
  %61 = getelementptr inbounds %java_Array, ptr %51, i32 0, i32 1
  %62 = load ptr, ptr %61
  %63 = getelementptr inbounds %java_Array, ptr %62, i32 0
  %64 = load float, float* %63
  %65 = fpext float %64 to double
  %66 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 1
  %67 = load ptr, ptr %66
  %68 = call i32(i8*,...) @printf(i8* %67, double %65)
  ; Line 16
  %69 = alloca %java_Array
  %70 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 0
  store i32 4, i32* %70
  %71 = alloca i8, i32 4
  %72 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  store ptr %71, ptr %72
  call void @llvm.memset.p0.i8(ptr %71, i8 0, i64 4, i1 false)
  %73 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  %74 = load ptr, ptr %73
  %75 = getelementptr inbounds i8, ptr %74, i32 0
  store i8 37, ptr %75
  %76 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  %77 = load ptr, ptr %76
  %78 = getelementptr inbounds i8, ptr %77, i32 1
  store i8 102, ptr %78
  %79 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  %80 = load ptr, ptr %79
  %81 = getelementptr inbounds i8, ptr %80, i32 2
  store i8 10, ptr %81
  %82 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  %83 = load ptr, ptr %82
  %84 = getelementptr inbounds i8, ptr %83, i32 3
  store i8 0, ptr %84
  %85 = alloca %java_Array
  %86 = getelementptr inbounds %java_Array, %java_Array* %85, i32 0, i32 0
  store i32 1, i32* %86
  %87 = alloca double, i32 1
  %88 = getelementptr inbounds %java_Array, %java_Array* %85, i32 0, i32 1
  store ptr %87, ptr %88
  call void @llvm.memset.p0.i64(ptr %87, i8 0, i64 4, i1 false)
  %89 = load %InstanceFields*, %InstanceFields** %local.0
  %90 = getelementptr inbounds %InstanceFields, %InstanceFields* %89, i32 0, i32 4
  %91 = load double, double* %90
  %92 = getelementptr inbounds %java_Array, %java_Array* %85, i32 0, i32 1
  %93 = load ptr, ptr %92
  %94 = getelementptr inbounds double, ptr %93, i32 0
  store double %91, ptr %94
  %95 = getelementptr inbounds %java_Array, ptr %85, i32 0, i32 1
  %96 = load ptr, ptr %95
  %97 = getelementptr inbounds %java_Array, ptr %96, i32 0
  %98 = load double, double* %97
  %99 = getelementptr inbounds %java_Array, %java_Array* %69, i32 0, i32 1
  %100 = load ptr, ptr %99
  %101 = call i32(i8*,...) @printf(i8* %100, double %98)
  ; Line 17
  ret i32 0
label1:
  ; %instance exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
