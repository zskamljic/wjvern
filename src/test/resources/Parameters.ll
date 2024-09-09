%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%Parameters = type { %Parameters_vtable_type* }
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%Parameters_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Parameters_vtable_data = global %Parameters_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Parameters_<init>()V"(%Parameters* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Parameters**
  store %Parameters* %param.0, %Parameters** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Parameters*, %Parameters** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Parameters*, %Parameters** %local.0
  %3 = getelementptr inbounds %Parameters, %Parameters* %2, i32 0, i32 0
  store %Parameters_vtable_type* @Parameters_vtable_data, %Parameters_vtable_type** %3
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Parameters_something(I)I"(%Parameters* %param.0, i32 %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Parameters**
  store %Parameters* %param.0, %Parameters** %local.0
  %local.1 = alloca i32*
  store i32 %param.1, i32* %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %a entered scope under name %local.1
  ; Line 3
  %1 = load i32, i32* %local.1
  ret i32 %1
label1:
  ; %this exited scope under name %local.0
  ; %a exited scope under name %local.1
  unreachable
}

define i32 @"Parameters_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 7
  %1 = alloca %Parameters
  call void @"Parameters_<init>()V"(%Parameters* %1)
  %local.0 = alloca ptr
  store %Parameters* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 8
  %2 = load %Parameters*, %Parameters** %local.0
  %3 = call i32 @"Parameters_something(I)I"(%Parameters* %2, i32 5)
  ret i32 %3
label1:
  ; %instance exited scope under name %local.0
  unreachable
}
