%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%Switch = type { %Switch_vtable_type* }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Switch_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Switch_vtable_data = global %Switch_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Switch_<init>()V"(%Switch* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %Switch, %Switch* %local.0, i32 0, i32 0
  store %Switch_vtable_type* @Switch_vtable_data, %Switch_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Switch_switchFunc(I)I"(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %value entered scope under name %local.0
  ; Line 3
  %0 = alloca ptr
  switch i32 %local.0, label %label6 [i32 1, label %label2 i32 2, label %label3 i32 3, label %label4 i32 4, label %label5]
label2:
  ; Line 4
  store i64 5, ptr %0
  br label %label7
label3:
  ; Line 5
  store i64 4, ptr %0
  br label %label7
label4:
  ; Line 6
  store i64 3, ptr %0
  br label %label7
label5:
  ; Line 7
  store i64 2, ptr %0
  br label %label7
label6:
  ; Line 8
  store i64 1, ptr %0
  br label %label7
label7:
  ; Line 3
  %1 = load i64, i64* %0
  %2 = trunc i64 %1 to i32
  ret i32 %2
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define i32 @"Switch_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = call i32 @"Switch_switchFunc(I)I"(i32 3)
  ret i32 %1
}
