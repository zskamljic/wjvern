%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%StaticFields = type { %StaticFields_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%StaticFields_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

@StaticFields_value = global i32 0

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@StaticFields_vtable_data = global %StaticFields_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 12, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"StaticFields_<init>()V"(%StaticFields* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %StaticFields**
  store %StaticFields* %param.0, %StaticFields** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %StaticFields*, %StaticFields** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %StaticFields*, %StaticFields** %local.0
  %3 = getelementptr inbounds %StaticFields, %StaticFields* %2, i32 0, i32 0
  store %StaticFields_vtable_type* @StaticFields_vtable_data, %StaticFields_vtable_type** %3
  %4 = load %StaticFields*, %StaticFields** %local.0
  %5 = getelementptr inbounds %StaticFields, %StaticFields* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"StaticFields_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 5
  %1 = load i32, i32* @StaticFields_value
  %2 = add i32 %1, 1
  store i32 %2, i32* @StaticFields_value
  ; Line 6
  %3 = load i32, i32* @StaticFields_value
  ret i32 %3
}
