%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%NativeMethods_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%NativeMethods = type { %NativeMethods_vtable_type* }

@NativeMethods_vtable_data = global %NativeMethods_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"NativeMethods_<init>"(%NativeMethods* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %NativeMethods, %NativeMethods* %this, i64 0, i32 0
  store %NativeMethods_vtable_type* @NativeMethods_vtable_data, %NativeMethods_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 3
  %1 = alloca [7 x i8]
  %2 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 0
  store i8 72, ptr %2
  %3 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 1
  store i8 101, ptr %3
  %4 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 2
  store i8 108, ptr %4
  %5 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 3
  store i8 108, ptr %5
  %6 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 4
  store i8 111, ptr %6
  %7 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 5
  store i8 33, ptr %7
  %8 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 6
  store i8 0, ptr %8
  %9 = call i32 @puts(ptr %1)
  ret i32 %9
}

declare i32 @puts(ptr) nounwind
