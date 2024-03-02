%"java/lang/Object" = type opaque
%Foroop = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%ForLoop_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%ForLoop = type { %ForLoop_vtable_type* }

@ForLoop_vtable_data = global %ForLoop_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"ForLoop_<init>"(%ForLoop* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %ForLoop, %ForLoop* %this, i64 0, i32 0
  store %ForLoop_vtable_type* @ForLoop_vtable_data, %ForLoop_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 3
  %i = alloca i32
  store i32 0, i32* %i
  br label %label0
label0:
  %1 = load i32, i32* %i
  %2 = icmp sge i32 %1, 5
  br i1 %2, label %label1, label %not_label1
not_label1:
  ; Line 4
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
  ; Line 3
  %14 = load i32, i32* %i
  %15 = add i32 %14, 1
  store i32 %15, i32* %i
  br label %label0
label1:
  ; Line 6
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
