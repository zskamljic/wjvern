%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%NativeMethods = type { }

define void @"NativeMethods_<init>"(%NativeMethods* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
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
