%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%VirtualMethods_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%VirtualMethods*)* }

%VirtualMethods = type { %VirtualMethods_vtable_type*, i32 }

define void @VirtualMethods_doSomething(%VirtualMethods* %this) personality ptr @__gxx_personality_v0 {
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

declare i32 @__gxx_personality_v0(...)

@VirtualMethods_vtable_data = global %VirtualMethods_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize",
  void(%VirtualMethods*)* @VirtualMethods_doSomething
}

define void @"VirtualMethods_<init>"(%VirtualMethods* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %this, i64 0, i32 0
  store %VirtualMethods_vtable_type* @VirtualMethods_vtable_data, %VirtualMethods_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  %instance = alloca %VirtualMethods
  ; Line 9
  %1 = alloca %VirtualMethods
  call void @"VirtualMethods_<init>"(%VirtualMethods* %1)
  %2 = load %VirtualMethods, %VirtualMethods* %1
  store %VirtualMethods %2, %VirtualMethods* %instance
  br label %label0
label0:
  ; Line 10
  %3 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %instance, i64 0, i32 0
  %4 = load %VirtualMethods_vtable_type*, %VirtualMethods_vtable_type** %3
  %5 = getelementptr inbounds %VirtualMethods_vtable_type, %VirtualMethods_vtable_type* %4, i64 0, i32 2
  %6 = load void(%VirtualMethods*)*, void(%VirtualMethods*)** %5
  call void %6(%VirtualMethods* %instance)
  ; Line 11
  %7 = getelementptr inbounds %VirtualMethods, %VirtualMethods* %instance, i64 0, i32 1
  %8 = load i32, i32* %7
  ret i32 %8
}

declare i32 @printf(ptr, ...) nounwind
