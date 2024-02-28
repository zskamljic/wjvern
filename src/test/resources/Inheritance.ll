%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%Parent_vtable_type = type { void(%Parent*)*, void(%Parent*)* }

%Parent = type { %Parent_vtable_type*, i32, i32 }

define void @Parent_parentMethod(%Parent* %this) {
label0:
  ; Line 6
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 1
  store i32 5, i32* %0
  ; Line 7
  ret void
}

define void @Parent_dynamic(%Parent* %this) {
label0:
  ; Line 10
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 2
  store i32 3, i32* %0
  ; Line 11
  ret void
}

@Parent_vtable_data = global %Parent_vtable_type {
  void(%Parent*)* @Parent_parentMethod,
  void(%Parent*)* @Parent_dynamic
}

define void @"Parent_<init>"(%Parent* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %0
  ret void
}

%Inheritance_vtable_type = type { void(%Parent*)*, void(%Inheritance*)*, void(%Inheritance*)* }

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
  %4 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %3, i64 0, i32 0
  %5 = load void(%Parent*)*, void(%Parent*)** %4
  %6 = bitcast %Inheritance* %instance to %Parent*
  call void %5(%Parent* %6)
  ; Line 29
  %7 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %8 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %7
  %9 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %8, i64 0, i32 2
  %10 = load void(%Inheritance*)*, void(%Inheritance*)** %9
  call void %10(%Inheritance* %instance)
  ; Line 30
  %11 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %12 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %11
  %13 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %12, i64 0, i32 1
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
