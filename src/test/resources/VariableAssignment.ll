%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%VariableAssignment = type { %VariableAssignment_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%VariableAssignment_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@VariableAssignment_vtable_data = global %VariableAssignment_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 9, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"VariableAssignment_<init>()V"(%VariableAssignment* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %VariableAssignment**
  store %VariableAssignment* %param.0, %VariableAssignment** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %VariableAssignment*, %VariableAssignment** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %VariableAssignment*, %VariableAssignment** %local.0
  %3 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %2, i32 0, i32 0
  store %VariableAssignment_vtable_type* @VariableAssignment_vtable_data, %VariableAssignment_vtable_type** %3
  %4 = load %VariableAssignment*, %VariableAssignment** %local.0
  %5 = getelementptr inbounds %VariableAssignment, %VariableAssignment* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"VariableAssignment_method()V"(%VariableAssignment* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %VariableAssignment**
  store %VariableAssignment* %param.0, %VariableAssignment** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 4
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"VariableAssignment_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 7
  %1 = alloca %VariableAssignment
  call void @"VariableAssignment_<init>()V"(%VariableAssignment* %1)
  %local.0 = alloca ptr
  store %VariableAssignment* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 8
  %2 = load %VariableAssignment*, %VariableAssignment** %local.0
  call void @"VariableAssignment_method()V"(%VariableAssignment* %2)
  ; Line 10
  %local.1 = alloca ptr
  store i32 1, ptr %local.1
  br label %label2
label2:
  ; %i entered scope under name %local.1
  ; Line 11
  %3 = load i32, i32* %local.1
  ret i32 %3
label1:
  ; %instance exited scope under name %local.0
  ; %i exited scope under name %local.1
  unreachable
}
