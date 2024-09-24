%"java/lang/Object" = type { ptr, ptr }
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%"java/lang/System" = type opaque
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%InstanceOf = type { %InstanceOf_vtable_type*, %java_TypeInfo*, i32 }
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
%InstanceOf_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/System_vtable_type" = type {  }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

declare i32 @llvm.eh.typeid.for(ptr)

declare ptr @__cxa_allocate_exception(i64)

declare void @__cxa_throw(ptr, ptr, ptr)

declare ptr @__cxa_begin_catch(ptr)

declare void @__cxa_end_catch()

@_ZTVN10__cxxabiv117__class_type_infoE = external global ptr
@_ZTVN10__cxxabiv119__pointer_type_infoE = external global ptr

@InstanceOf_vtable_data = global %InstanceOf_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 2, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr null }

define void @"InstanceOf_<init>(I)V"(%InstanceOf* %param.0, i32 %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %InstanceOf**
  store %InstanceOf* %param.0, %InstanceOf** %local.0
  %local.1 = alloca i32*
  store i32 %param.1, i32* %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %number entered scope under name %local.1
  ; Line 4
  %1 = load %InstanceOf*, %InstanceOf** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %InstanceOf*, %InstanceOf** %local.0
  %3 = getelementptr inbounds %InstanceOf, %InstanceOf* %2, i32 0, i32 0
  store %InstanceOf_vtable_type* @InstanceOf_vtable_data, %InstanceOf_vtable_type** %3
  %4 = load %InstanceOf*, %InstanceOf** %local.0
  %5 = getelementptr inbounds %InstanceOf, %InstanceOf* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 5
  %6 = load %InstanceOf*, %InstanceOf** %local.0
  %7 = load i32, i32* %local.1
  %8 = getelementptr inbounds %InstanceOf, %InstanceOf* %6, i32 0, i32 2
  store i32 %7, i32* %8
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %number exited scope under name %local.1
  unreachable
}

define void @"InstanceOf_main([Ljava/lang/String;)V"(%java_Array* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %java_Array**
  store %java_Array* %param.0, %java_Array** %local.0
  br label %label2
label2:
  ; %args entered scope under name %local.0
  ; Line 9
  %1 = alloca %InstanceOf
  call void @"InstanceOf_<init>(I)V"(%InstanceOf* %1, i32 5)
  %local.1 = alloca ptr
  store %InstanceOf* %1, ptr %local.1
  br label %label4
label4:
  ; %object entered scope under name %local.1
  ; Line 10
  %2 = load %"java/lang/Object"*, %"java/lang/Object"** %local.1
  %3 = call i1 @instanceof(ptr %2, i32 2)
  %4 = sext i1 %3 to i32
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %label1, label %label5
label5:
  %6 = load %"java/lang/Object"*, %"java/lang/Object"** %local.1
  %7 = ptrtoint ptr %6 to i32
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %label6, label %label7
label6:
  br label %label8
label7:
  br label %label8
label8:
  %9 = phi %"java/lang/Object"* [null, %label6], [%6, %label7]
  %10 = call i1 @instanceof(ptr %6, i32 2)
  br i1 %10, label %label9, label %label10
label10:
  call void @__cxa_throw(ptr null, ptr null, ptr null)
  unreachable
label9:
  %local.2 = alloca ptr
  store %"java/lang/Object"* %9, ptr %local.2
  br label %label0
label0:
  ; %iof entered scope under name %local.2
  ; Line 11
  %11 = load %InstanceOf*, %InstanceOf** %local.2
  %12 = getelementptr inbounds %InstanceOf, %InstanceOf* %11, i32 0, i32 2
  %13 = load i32, i32* %12
  call void @"java/lang/System_exit(I)V"(i32 %13)
  br label %label1
label1:
  ; %iof exited scope under name %local.2
  ; Line 13
  ret void
label3:
  ; %args exited scope under name %local.0
  ; %object exited scope under name %local.1
  unreachable
}
