%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%VirtualMethods_vtable_type = type { void(%VirtualMethods*)* }

%VirtualMethods = type { %VirtualMethods_vtable_type*, i32 }

define void @VirtualMethods_doSomething(%VirtualMethods* %this) {
label0:
  ; Line 4
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
  ; Line 5
  %11 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %this, i64 0, i32 1
  store i32 5, i32* %11
  ; Line 6
  ret void
}

@VirtualMethods_vtable_data = global %VirtualMethods_vtable_type {
  void(%VirtualMethods*)* @VirtualMethods_doSomething
}

define void @"VirtualMethods_<init>"(%VirtualMethods* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %this, i64 0, i32 0
  store %VirtualMethods_vtable_type* @VirtualMethods_vtable_data, %VirtualMethods_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 9
  %1 = alloca %VirtualMethods
  call void @"VirtualMethods_<init>"(%VirtualMethods* %1)
  %instance = bitcast %VirtualMethods* %1 to %VirtualMethods*
  br label %label0
label0:
  ; Line 10
  %2 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %instance, i64 0, i32 0
  %3 = load %VirtualMethods_vtable_type*, %VirtualMethods_vtable_type** %2
  %4 = getelementptr inbounds %VirtualMethods_vtable_type, %VirtualMethods_vtable_type* %3, i64 0, i32 0
  %5 = load void(%VirtualMethods*)*, void(%VirtualMethods*)** %4
  call void %5(%VirtualMethods* %instance)
  ; Line 11
  %6 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %instance, i64 0, i32 1
  %7 = load i32, i32* %6
  ret i32 %7
}

declare i32 @printf(ptr, ...) nounwind
