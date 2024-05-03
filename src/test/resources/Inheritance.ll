%"java/lang/Object" = type { ptr }
%Parent = type { ptr, i32, i32 }

declare void @"Parent_<init>"(%Parent*)

declare void @Parent_parentMethod(%Parent*)
declare void @Parent_dynamic(%Parent*)
declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%Inheritance_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Inheritance*)*, void(%Inheritance*)* }

%Inheritance = type { %Inheritance_vtable_type*, i32, i32, i32 }

define void @Inheritance_childMethod(%Inheritance* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 18
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 3
  store i32 2, i32* %0
  ; Line 19
  ret void
}

define void @Inheritance_dynamic(%Inheritance* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 23
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 2
  store i32 5, i32* %0
  ; Line 24
  ret void
}

declare i32 @__gxx_personality_v0(...)

@Inheritance_vtable_data = global %Inheritance_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize",
  void(%Parent*)* @Parent_parentMethod,
  void(%Inheritance*)* @Inheritance_dynamic,
  void(%Inheritance*)* @Inheritance_childMethod
}

define void @"Inheritance_<init>"(%Inheritance* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 14
  call void @"Parent_<init>"(%Parent* %this)
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %this, i64 0, i32 0
  store %Inheritance_vtable_type* @Inheritance_vtable_data, %Inheritance_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 27
  %1 = alloca %Inheritance
  call void @"Inheritance_<init>"(%Inheritance* %1)
  %local.0 = alloca ptr
  store %Inheritance* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %Inheritance*, ptr %local.0
  %instance = bitcast ptr %2 to %Inheritance*
  ; Line 28
  %3 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %4 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %3
  %5 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %4, i64 0, i32 2
  %6 = load void(%Parent*)*, void(%Parent*)** %5
  %7 = bitcast %Inheritance* %instance to %Parent*
  call void %6(%Parent* %7)
  ; Line 29
  %8 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %9 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %8
  %10 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %9, i64 0, i32 4
  %11 = load void(%Inheritance*)*, void(%Inheritance*)** %10
  call void %11(%Inheritance* %instance)
  ; Line 30
  %12 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 0
  %13 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %12
  %14 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %13, i64 0, i32 3
  %15 = load void(%Inheritance*)*, void(%Inheritance*)** %14
  call void %15(%Inheritance* %instance)
  ; Line 32
  %16 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 1
  %17 = load i32, i32* %16
  %18 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 3
  %19 = load i32, i32* %18
  %20 = add i32 %17, %19
  %21 = getelementptr inbounds %Inheritance, %Inheritance* %instance, i64 0, i32 2
  %22 = load i32, i32* %21
  %23 = add i32 %20, %22
  ret i32 %23
}
