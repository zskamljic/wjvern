%"java/lang/Object" = type { ptr }

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
  %0 = getelementptr inbounds %WhileLoop, %WhileLoop* %this, i64 0, i32 0
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
  %3 = alloca [4 x i8]
  %4 = getelementptr inbounds [4 x i8], ptr %3, i64 0, i32 0
  store i8 37, ptr %4
  %5 = getelementptr inbounds [4 x i8], ptr %3, i64 0, i32 1
  store i8 100, ptr %5
  %6 = getelementptr inbounds [4 x i8], ptr %3, i64 0, i32 2
  store i8 10, ptr %6
  %7 = getelementptr inbounds [4 x i8], ptr %3, i64 0, i32 3
  store i8 0, ptr %7
  %8 = alloca [1 x i32]
  %9 = getelementptr inbounds [1 x i32], ptr %8, i64 0, i32 0
  %10 = load i32, i32* %i
  store i32 %10, ptr %9
  %11 = getelementptr inbounds [1 x i32], ptr %8, i64 0, i32 0
  %12 = load i32, i32* %11
  %13 = call i32 @printf(ptr %3, i32 %12)
  ; Line 6
  %14 = load i32, i32* %i
  %15 = add i32 %14, -1
  store i32 %15, i32* %i
  br label %label0
label2:
  ; Line 8
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
