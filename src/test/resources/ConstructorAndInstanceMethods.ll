%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%ConstructorAndInstanceMethods_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%ConstructorAndInstanceMethods = type { %ConstructorAndInstanceMethods_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@ConstructorAndInstanceMethods_vtable_data = global %ConstructorAndInstanceMethods_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ConstructorAndInstanceMethods_<init>()V"(%ConstructorAndInstanceMethods* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 2
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %ConstructorAndInstanceMethods, %ConstructorAndInstanceMethods* %this, i64 0, i32 0
  store %ConstructorAndInstanceMethods_vtable_type* @ConstructorAndInstanceMethods_vtable_data, %ConstructorAndInstanceMethods_vtable_type** %0
  ; Line 3
  %1 = alloca [13 x i8]
  %2 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 0
  store i8 67, ptr %2
  %3 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 1
  store i8 111, ptr %3
  %4 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 2
  store i8 110, ptr %4
  %5 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 3
  store i8 115, ptr %5
  %6 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 4
  store i8 116, ptr %6
  %7 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 5
  store i8 114, ptr %7
  %8 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 6
  store i8 117, ptr %8
  %9 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 7
  store i8 99, ptr %9
  %10 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 8
  store i8 116, ptr %10
  %11 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 9
  store i8 111, ptr %11
  %12 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 10
  store i8 114, ptr %12
  %13 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 11
  store i8 10, ptr %13
  %14 = getelementptr inbounds [13 x i8], ptr %1, i64 0, i32 12
  store i8 0, ptr %14
  %15 = alloca [0 x i32]
  %16 = call i32 @printf(ptr %1)
  ; Line 4
  ret void
}

define void @"ConstructorAndInstanceMethods_method()V"(%ConstructorAndInstanceMethods* %this) personality ptr @__gxx_personality_v0 {
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

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %ConstructorAndInstanceMethods
  call void @"ConstructorAndInstanceMethods_<init>()V"(%ConstructorAndInstanceMethods* %1)
  call void @"ConstructorAndInstanceMethods_method()V"(%ConstructorAndInstanceMethods* %1)
  ; Line 13
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
