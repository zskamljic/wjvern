%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%ConstructorAndInstanceMethods_vtable_type = type {  }

%ConstructorAndInstanceMethods = type { %ConstructorAndInstanceMethods_vtable_type* }

@ConstructorAndInstanceMethods_vtable_data = global %ConstructorAndInstanceMethods_vtable_type {
}

define void @"ConstructorAndInstanceMethods_<init>"(%ConstructorAndInstanceMethods* %this) {
label0:
  ; Line 2
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ; Line 3
  %0 = alloca [13 x i8]
  %1 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 0
  store i8 67, ptr %1
  %2 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 1
  store i8 111, ptr %2
  %3 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 2
  store i8 110, ptr %3
  %4 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 3
  store i8 115, ptr %4
  %5 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 4
  store i8 116, ptr %5
  %6 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 5
  store i8 114, ptr %6
  %7 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 6
  store i8 117, ptr %7
  %8 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 7
  store i8 99, ptr %8
  %9 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 8
  store i8 116, ptr %9
  %10 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 9
  store i8 111, ptr %10
  %11 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 10
  store i8 114, ptr %11
  %12 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 11
  store i8 10, ptr %12
  %13 = getelementptr inbounds [13 x i8], ptr %0, i64 0, i32 12
  store i8 0, ptr %13
  %14 = alloca [0 x i32]
  %15 = call i32 @printf(ptr %0)
  ; Line 4
  ret void
}

define void @ConstructorAndInstanceMethods_method(%ConstructorAndInstanceMethods* %this) {
label0:
  ; Line 7
  %0 = alloca [8 x i8]
  %1 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 0
  store i8 109, ptr %1
  %2 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 1
  store i8 101, ptr %2
  %3 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 2
  store i8 116, ptr %3
  %4 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 3
  store i8 104, ptr %4
  %5 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 4
  store i8 111, ptr %5
  %6 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 5
  store i8 100, ptr %6
  %7 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 6
  store i8 10, ptr %7
  %8 = getelementptr inbounds [8 x i8], ptr %0, i64 0, i32 7
  store i8 0, ptr %8
  %9 = alloca [0 x i32]
  %10 = call i32 @printf(ptr %0)
  ; Line 8
  ret void
}

define i32 @main() {
  ; Line 11
  %1 = alloca %ConstructorAndInstanceMethods
  call void @"ConstructorAndInstanceMethods_<init>"(%ConstructorAndInstanceMethods* %1)
  call void @"ConstructorAndInstanceMethods_method"(%ConstructorAndInstanceMethods* %1)
  ; Line 13
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
