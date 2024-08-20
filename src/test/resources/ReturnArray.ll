%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%ReturnArray = type { %ReturnArray_vtable_type* }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%ReturnArray_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ReturnArray_vtable_data = global %ReturnArray_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ReturnArray_<init>()V"(%ReturnArray* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %ReturnArray, %ReturnArray* %local.0, i32 0, i32 0
  store %ReturnArray_vtable_type* @ReturnArray_vtable_data, %ReturnArray_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %java_Array
  call void @returnArray(ptr sret(%java_Array*) %1)
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  %3 = load i32, ptr %2
  ret i32 %3
}

define void @returnArray(ptr sret(%java_Array) %0) personality ptr @__gxx_personality_v0 {
  ; Line 7
  %2 = alloca %java_Array
  %3 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 0
  store i32 3, i32* %3
  %4 = alloca i32, i32 3
  %5 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  store ptr %4, ptr %5
  call void @llvm.memset.p0.i32(ptr %4, i8 0, i64 12, i1 false)
  %6 = load %java_Array, %java_Array* %2
  store %java_Array %6, %java_Array* %0
  ret void
}
