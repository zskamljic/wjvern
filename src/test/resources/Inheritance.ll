%"java/lang/Object" = type opaque
%Parent = type opaque

declare void @"Parent_<init>"(%Parent* %this)
declare void @Parent_parentMethod(%Parent* %this)
declare void @Parent_dynamic(%Parent* %this)
declare void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"* %this, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"* %this) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"* %this, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"* %this)

%Inheritance_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Inheritance*)*, void(%Inheritance*)* }

%Inheritance = type { %Inheritance_vtable_type*, i32, i32, i32 }

define void @Inheritance_childMethod(%Inheritance* %this) {
label0:
  ; Line 18
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 3
  store i32 2, i32* %0
  ; Line 19
  ret void
}

define void @Inheritance_dynamic(%Inheritance* %this) {
label0:
  ; Line 23
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 2
  store i32 5, i32* %0
  ; Line 24
  ret void
}

@Inheritance_vtable_data = global %Inheritance_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize",
  void(%Parent*)* @Parent_parentMethod,
  void(%Inheritance*)* @Inheritance_dynamic,
  void(%Inheritance*)* @Inheritance_childMethod
}

define void @"Inheritance_<init>"(%Inheritance* %this) {
label0:
  ; Line 14
  call void @"Parent_<init>"(%Parent* %this)
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 0
  store %Inheritance_vtable_type* @Inheritance_vtable_data, %Inheritance_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 27
  %1 = alloca %Inheritance
  call void @"Inheritance_<init>"(%Inheritance* %1)
  %instance = bitcast %Inheritance* %1 to %Inheritance*
  br label %label0
label0:
  ; Line 28
  %2 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %3 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %2
  %4 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %3, i64 0, i32 2
  %5 = load void(%Parent*)*, void(%Parent*)** %4
  %6 = bitcast %Inheritance* %instance to %Parent*
  call void %5(%Parent* %6)
  ; Line 29
  %7 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %8 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %7
  %9 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %8, i64 0, i32 4
  %10 = load void(%Inheritance*)*, void(%Inheritance*)** %9
  call void %10(%Inheritance* %instance)
  ; Line 30
  %11 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %12 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %11
  %13 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %12, i64 0, i32 3
  %14 = load void(%Inheritance*)*, void(%Inheritance*)** %13
  call void %14(%Inheritance* %instance)
  ; Line 32
  %15 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 1
  %16 = load i32, i32* %15
  %17 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 3
  %18 = load i32, i32* %17
  %19 = add i32 %16, %18
  %20 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 2
  %21 = load i32, i32* %20
  %22 = add i32 %19, %21
  ret i32 %22
}
