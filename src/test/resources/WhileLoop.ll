%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%WhileLoop_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%WhileLoop = type { %WhileLoop_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@WhileLoop_vtable_data = global %WhileLoop_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"WhileLoop_<init>()V"(%WhileLoop* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %WhileLoop, %WhileLoop* %this, i32 0, i32 0
  store %WhileLoop_vtable_type* @WhileLoop_vtable_data, %WhileLoop_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store i32 10, ptr %local.0
  br label %label0
label0:
  %i = bitcast ptr %local.0 to i32*
  ; Line 4
  %1 = load i32, i32* %i
  %2 = icmp sle i32 %1, 0
  br i1 %2, label %label2, label %not_label2
not_label2:
  ; Line 5
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
  %23 = getelementptr inbounds %java_Array, %java_Array* %19, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds i32, ptr %24, i32 0
  %26 = load i32, i32* %i
  store i32 %26, ptr %25
  %27 = getelementptr inbounds %java_Array, ptr %19, i32 0, i32 1
  %28 = load ptr, ptr %27
  %29 = getelementptr inbounds %java_Array, ptr %28, i32 0
  %30 = load i32, i32* %29
  %31 = getelementptr inbounds %java_Array, ptr %3, i32 0, i32 1
  %32 = load ptr, ptr %31
  %33 = call i32 @printf(ptr %32, i32 %30)
  ; Line 6
  %34 = load i32, i32* %i
  %35 = add i32 %34, -1
  store i32 %35, i32* %i
  br label %label0
label2:
  ; Line 8
  ret i32 0
}

declare i32 @printf(%java_Array, ...) nounwind
