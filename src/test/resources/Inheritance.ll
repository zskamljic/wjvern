%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%Parent = type { ptr, i32, i32 }
%java_Array = type { i32, ptr }
%Inheritance = type { %Inheritance_vtable_type*, i32, i32, i32 }
declare void @"Parent_<init>()V"(%Parent*)

declare void @"Parent_parentMethod()V"(%Parent*)
declare void @"Parent_dynamic()V"(%Parent*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Parent_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Parent*)* }
%Inheritance_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Inheritance*)*, void(%Inheritance*)* }

define void @"Inheritance_childMethod()V"(%Inheritance* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 18
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %local.0, i32 0, i32 3
  store i32 2, i32* %0
  ; Line 19
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"Inheritance_dynamic()V"(%Inheritance* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 23
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %local.0, i32 0, i32 2
  store i32 5, i32* %0
  ; Line 24
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Inheritance_vtable_data = global %Inheritance_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  void(%Parent*)* @"Parent_parentMethod()V",
  void(%Inheritance*)* @"Inheritance_dynamic()V",
  void(%Inheritance*)* @"Inheritance_childMethod()V"
}

define void @"Inheritance_<init>()V"(%Inheritance* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 14
  call void @"Parent_<init>()V"(%Parent* %local.0)
  %0 = getelementptr inbounds %Inheritance, %Inheritance* %local.0, i32 0, i32 0
  store %Inheritance_vtable_type* @Inheritance_vtable_data, %Inheritance_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Inheritance_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 27
  %1 = alloca %Inheritance
  call void @"Inheritance_<init>()V"(%Inheritance* %1)
  %local.0 = alloca ptr
  store %Inheritance* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 28
  %2 = load %Inheritance*, %Inheritance** %local.0
  %3 = getelementptr inbounds %Inheritance, %Inheritance* %2, i32 0, i32 0
  %4 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %3
  %5 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %4, i32 0, i32 3
  %6 = load void(%Parent*)*, void(%Parent*)** %5
  %7 = bitcast %Inheritance* %2 to %Parent*
  call void %6(%Parent* %7)
  ; Line 29
  %8 = load %Inheritance*, %Inheritance** %local.0
  %9 = getelementptr inbounds %Inheritance, %Inheritance* %8, i32 0, i32 0
  %10 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %9
  %11 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %10, i32 0, i32 5
  %12 = load void(%Inheritance*)*, void(%Inheritance*)** %11
  call void %12(%Inheritance* %8)
  ; Line 30
  %13 = load %Inheritance*, %Inheritance** %local.0
  %14 = getelementptr inbounds %Inheritance, %Inheritance* %13, i32 0, i32 0
  %15 = load %Inheritance_vtable_type*, %Inheritance_vtable_type** %14
  %16 = getelementptr inbounds %Inheritance_vtable_type, %Inheritance_vtable_type* %15, i32 0, i32 4
  %17 = load void(%Inheritance*)*, void(%Inheritance*)** %16
  call void %17(%Inheritance* %13)
  ; Line 32
  %18 = load %Inheritance*, %Inheritance** %local.0
  %19 = getelementptr inbounds %Inheritance, %Inheritance* %18, i32 0, i32 1
  %20 = load i32, i32* %19
  %21 = load %Inheritance*, %Inheritance** %local.0
  %22 = getelementptr inbounds %Inheritance, %Inheritance* %21, i32 0, i32 3
  %23 = load i32, i32* %22
  %24 = add i32 %20, %23
  %25 = load %Inheritance*, %Inheritance** %local.0
  %26 = getelementptr inbounds %Inheritance, %Inheritance* %25, i32 0, i32 2
  %27 = load i32, i32* %26
  %28 = add i32 %24, %27
  ret i32 %28
label1:
  ; %instance exited scope under name %local.0
  unreachable
}
