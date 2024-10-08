%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%WhileLoop = type { %WhileLoop_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%WhileLoop_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@WhileLoop_vtable_data = global %WhileLoop_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 10, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"WhileLoop_<init>()V"(%WhileLoop* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %WhileLoop**
  store %WhileLoop* %param.0, %WhileLoop** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %WhileLoop*, %WhileLoop** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %WhileLoop*, %WhileLoop** %local.0
  %3 = getelementptr inbounds %WhileLoop, %WhileLoop* %2, i32 0, i32 0
  store %WhileLoop_vtable_type* @WhileLoop_vtable_data, %WhileLoop_vtable_type** %3
  %4 = load %WhileLoop*, %WhileLoop** %local.0
  %5 = getelementptr inbounds %WhileLoop, %WhileLoop* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"WhileLoop_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store i32 10, ptr %local.0
  br label %label0
label0:
  ; %i entered scope under name %local.0
  ; Line 4
  %1 = load i32, i32* %local.0
  %2 = icmp sle i32 %1, 0
  br i1 %2, label %label2, label %label3
label3:
  ; Line 5
  %3 = alloca %java_Array
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  store i32 4, i32* %4
  %5 = alloca i8, i32 4
  %6 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  store ptr %5, ptr %6
  call void @llvm.memset.p0.i8(ptr %5, i8 0, i64 4, i1 false)
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
  call void @llvm.memset.p0.i32(ptr %21, i8 0, i64 4, i1 false)
  %23 = getelementptr inbounds %java_Array, %java_Array* %19, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds i32, ptr %24, i32 0
  %26 = load i32, i32* %local.0
  store i32 %26, ptr %25
  %27 = getelementptr inbounds %java_Array, ptr %19, i32 0, i32 1
  %28 = load ptr, ptr %27
  %29 = getelementptr inbounds %java_Array, ptr %28, i32 0
  %30 = load i32, i32* %29
  %31 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %32 = load ptr, ptr %31
  %33 = call i32(i8*,...) @printf(i8* %32, i32 %30)
  ; Line 6
  %34 = load i32, i32* %local.0
  %35 = add i32 %34, -1
  store i32 %35, i32* %local.0
  br label %label0
label2:
  ; Line 8
  ret i32 0
label1:
  ; %i exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
