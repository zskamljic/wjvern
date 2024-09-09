%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%"java/lang/System" = type opaque
%java_Array = type { i32, ptr }
%MutableParameters = type { %MutableParameters_vtable_type* }
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/System_exit(I)V"(i32)
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%MutableParameters_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/System_vtable_type" = type {  }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@MutableParameters_vtable_data = global %MutableParameters_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"MutableParameters_<init>()V"(%MutableParameters* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %MutableParameters**
  store %MutableParameters* %param.0, %MutableParameters** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %MutableParameters*, %MutableParameters** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %MutableParameters*, %MutableParameters** %local.0
  %3 = getelementptr inbounds %MutableParameters, %MutableParameters* %2, i32 0, i32 0
  store %MutableParameters_vtable_type* @MutableParameters_vtable_data, %MutableParameters_vtable_type** %3
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"MutableParameters_main([Ljava/lang/String;)V"(%java_Array* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %java_Array**
  store %java_Array* %param.0, %java_Array** %local.0
  br label %label0
label0:
  ; %args entered scope under name %local.0
  ; Line 3
  %1 = load %java_Array*, %java_Array** %local.0
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  %3 = load i32, ptr %2
  %4 = call i32 @"MutableParameters_mutateParams(I)I"(i32 %3)
  call void @"java/lang/System_exit(I)V"(i32 %4)
  ; Line 4
  ret void
label1:
  ; %args exited scope under name %local.0
  unreachable
}

define i32 @"MutableParameters_mutateParams(I)I"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %a entered scope under name %local.0
  ; Line 7
  %1 = load i32, i32* %local.0
  %2 = add i32 %1, 1
  store i32 %2, i32* %local.0
  ; Line 8
  %3 = load i32, i32* %local.0
  ret i32 %3
label1:
  ; %a exited scope under name %local.0
  unreachable
}
