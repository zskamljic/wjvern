%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%ForEach = type { %ForEach_vtable_type* }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%ForEach_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ForEach_vtable_data = global %ForEach_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ForEach_<init>()V"(%ForEach* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %ForEach, %ForEach* %local.0, i32 0, i32 0
  store %ForEach_vtable_type* @ForEach_vtable_data, %ForEach_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"ForEach_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 3, i32* %2
  %3 = alloca i32, i32 3
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i32(ptr %3, i8 0, i64 12, i1 false)
  %local.0 = alloca ptr
  store %java_Array* %1, ptr %local.0
  br label %label2
label2:
  ; %array entered scope under name %local.0
  ; Line 5
  %5 = load %java_Array*, %java_Array** %local.0
  %local.1 = alloca ptr
  store %java_Array* %5, ptr %local.1
  %6 = load %java_Array*, %java_Array** %local.1
  %7 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 0
  %8 = load i32, ptr %7
  %local.2 = alloca ptr
  store i32 %8, ptr %local.2
  %local.3 = alloca ptr
  store i32 0, ptr %local.3
  br label %label4
label4:
  %9 = load i32, i32* %local.2
  %10 = load i32, i32* %local.3
  %11 = icmp sge i32 %10, %9
  br i1 %11, label %label5, label %label6
label6:
  %12 = load i32, i32* %local.3
  %13 = load %java_Array*, %java_Array** %local.1
  %14 = getelementptr inbounds %java_Array, %java_Array* %13, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i32, ptr %15, i32 %12
  %17 = load i32, ptr %16
  %local.4 = alloca ptr
  store i32 %17, ptr %local.4
  br label %label0
label0:
  ; %i entered scope under name %local.4
  ; Line 6
  %18 = load i32, i32* %local.4
  call void @"ForEach_print(I)V"(i32 %18)
  br label %label1
label1:
  ; %i exited scope under name %local.4
  ; Line 5
  %19 = load i32, i32* %local.3
  %20 = add i32 %19, 1
  store i32 %20, i32* %local.3
  br label %label4
label5:
  ; Line 9
  ret i32 0
label3:
  ; %array exited scope under name %local.0
  unreachable
}

define void @"ForEach_print(I)V"(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %number entered scope under name %local.0
  ; Line 13
  %0 = alloca %java_Array
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  store i32 4, i32* %1
  %2 = alloca i8, i32 4
  %3 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  store ptr %2, ptr %3
  call void @llvm.memset.p0.i8(ptr %2, i8 0, i64 4, i1 false)
  %4 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %5 = load ptr, ptr %4
  %6 = getelementptr inbounds i8, ptr %5, i32 0
  store i8 37, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 1
  store i8 100, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 2
  store i8 10, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 3
  store i8 0, ptr %15
  %local.1 = alloca ptr
  store %java_Array* %0, ptr %local.1
  br label %label2
label2:
  ; %pattern entered scope under name %local.1
  ; Line 14
  %16 = load %java_Array*, %java_Array** %local.1
  %17 = alloca %java_Array
  %18 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 0
  store i32 1, i32* %18
  %19 = alloca i32, i32 1
  %20 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  store ptr %19, ptr %20
  call void @llvm.memset.p0.i32(ptr %19, i8 0, i64 4, i1 false)
  %21 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i32, ptr %22, i32 0
  store i32 %local.0, ptr %23
  %24 = getelementptr inbounds %java_Array, ptr %17, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = getelementptr inbounds %java_Array, ptr %25, i32 0
  %27 = load i32, i32* %26
  %28 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = call i32(i8*,...) @printf(i8* %29, i32 %27)
  ; Line 15
  ret void
label1:
  ; %number exited scope under name %local.0
  ; %pattern exited scope under name %local.1
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
