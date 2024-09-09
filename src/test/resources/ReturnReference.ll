%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%ReturnReference = type { %ReturnReference_vtable_type* }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%ReturnReference_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%ReturnReference*)* }
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }

define i32 @"ReturnReference_returnValue()I"(%ReturnReference* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ReturnReference**
  store %ReturnReference* %param.0, %ReturnReference** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 3
  ret i32 4
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

@ReturnReference_vtable_data = global %ReturnReference_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  i32(%ReturnReference*)* @"ReturnReference_returnValue()I"
}

define void @"ReturnReference_<init>()V"(%ReturnReference* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ReturnReference**
  store %ReturnReference* %param.0, %ReturnReference** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %ReturnReference*, %ReturnReference** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ReturnReference*, %ReturnReference** %local.0
  %3 = getelementptr inbounds %ReturnReference, %ReturnReference* %2, i32 0, i32 0
  store %ReturnReference_vtable_type* @ReturnReference_vtable_data, %ReturnReference_vtable_type** %3
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"ReturnReference_createInstance()LReturnReference;"(ptr sret(%ReturnReference) %0) personality ptr @__gxx_personality_v0 {
  ; Line 7
  %2 = alloca %ReturnReference
  call void @"ReturnReference_<init>()V"(%ReturnReference* %2)
  %3 = load %ReturnReference, %ReturnReference* %2
  store %ReturnReference %3, %ReturnReference* %0
  ret void
}

define i32 @"ReturnReference_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 11
  %1 = alloca %ReturnReference
  call void @"ReturnReference_createInstance()LReturnReference;"(ptr sret(%ReturnReference*) %1)
  %local.0 = alloca ptr
  store %ReturnReference* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 12
  %2 = load %ReturnReference*, %ReturnReference** %local.0
  %3 = getelementptr inbounds %ReturnReference, %ReturnReference* %2, i32 0, i32 0
  %4 = load %ReturnReference_vtable_type*, %ReturnReference_vtable_type** %3
  %5 = getelementptr inbounds %ReturnReference_vtable_type, %ReturnReference_vtable_type* %4, i32 0, i32 3
  %6 = load i32(%ReturnReference*)*, i32(%ReturnReference*)** %5
  %7 = call i32 %6(%ReturnReference* %2)
  ret i32 %7
label1:
  ; %instance exited scope under name %local.0
  unreachable
}
