%"java/lang/Object" = type { ptr, ptr }
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%Switch = type { %Switch_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Switch_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Switch_vtable_data = global %Switch_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 2, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"Switch_<init>()V"(%Switch* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Switch**
  store %Switch* %param.0, %Switch** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Switch*, %Switch** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Switch*, %Switch** %local.0
  %3 = getelementptr inbounds %Switch, %Switch* %2, i32 0, i32 0
  store %Switch_vtable_type* @Switch_vtable_data, %Switch_vtable_type** %3
  %4 = load %Switch*, %Switch** %local.0
  %5 = getelementptr inbounds %Switch, %Switch* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Switch_switchFunc(I)I"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 4
  %1 = load i32, i32* %local.0
  switch i32 %1, label %label6 [i32 1, label %label2 i32 2, label %label3 i32 3, label %label4 i32 4, label %label5]
label2:
  ; Line 5
  br label %label7
label3:
  ; Line 6
  br label %label7
label4:
  ; Line 7
  br label %label7
label5:
  ; Line 8
  br label %label7
label6:
  ; Line 9
  br label %label7
label7:
  %2 = phi i32 [3, %label4], [2, %label5], [1, %label6], [5, %label2], [4, %label3]
  ; Line 4
  ret i32 %2
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define i32 @"Switch_switchFunc2(I)I"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 15
  %1 = load i32, i32* %local.0
  switch i32 %1, label %label5 [i32 1, label %label2 i32 10, label %label3 i32 100, label %label4]
label2:
  ; Line 16
  br label %label6
label3:
  ; Line 17
  br label %label6
label4:
  ; Line 18
  br label %label6
label5:
  ; Line 19
  br label %label6
label6:
  %2 = phi i32 [500, %label4], [3, %label5], [5, %label2], [50, %label3]
  ; Line 15
  ret i32 %2
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define i32 @"Switch_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 24
  %1 = call i32 @"Switch_switchFunc(I)I"(i32 3)
  %2 = call i32 @"Switch_switchFunc2(I)I"(i32 %1)
  ret i32 %2
}
