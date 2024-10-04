%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%Parent = type { %Parent_vtable_type*, %java_TypeInfo*, i32, i32 }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%Parent_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Parent*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Parent_vtable_data = global %Parent_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  void(%Parent*)* @"Parent_parentMethod()V",
  void(%Parent*)* @"Parent_dynamic()V"
}

@typeInfo_types = private global [2 x i32] [i32 9, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"Parent_<init>()V"(%Parent* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Parent**
  store %Parent* %param.0, %Parent** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Parent*, %Parent** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Parent*, %Parent** %local.0
  %3 = getelementptr inbounds %Parent, %Parent* %2, i32 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %3
  %4 = load %Parent*, %Parent** %local.0
  %5 = getelementptr inbounds %Parent, %Parent* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"Parent_parentMethod()V"(%Parent* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Parent**
  store %Parent* %param.0, %Parent** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 6
  %1 = load %Parent*, %Parent** %local.0
  %2 = getelementptr inbounds %Parent, %Parent* %1, i32 0, i32 2
  store i32 5, i32* %2
  ; Line 7
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"Parent_dynamic()V"(%Parent* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Parent**
  store %Parent* %param.0, %Parent** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 10
  %1 = load %Parent*, %Parent** %local.0
  %2 = getelementptr inbounds %Parent, %Parent* %1, i32 0, i32 3
  store i32 3, i32* %2
  ; Line 11
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}
