%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%Parent_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, void(%Parent*)*, void(%Parent*)* }

%Parent = type { %Parent_vtable_type*, i32, i32 }

define void @"Parent_parentMethod()V"(%Parent* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 6
  %0 = getelementptr inbounds %Parent, %Parent* %local.0, i32 0, i32 1
  store i32 5, i32* %0
  ; Line 7
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"Parent_dynamic()V"(%Parent* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 10
  %0 = getelementptr inbounds %Parent, %Parent* %local.0, i32 0, i32 2
  store i32 3, i32* %0
  ; Line 11
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

declare i32 @__gxx_personality_v0(...)
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

define void @"Parent_<init>()V"(%Parent* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %Parent, %Parent* %local.0, i32 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}
