%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%"java/lang/Comparable" = type { ptr, ptr }
%"java/lang/System" = type opaque
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%InterfaceCalls = type { %InterfaceCalls_vtable_type*, %java_TypeInfo*, i32 }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/System_exit(I)V"(i32)
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%InterfaceCalls_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%InterfaceCalls*, %InterfaceCalls)*, i32(%InterfaceCalls*, %"java/lang/Object")* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%"java/lang/Comparable_vtable_type" = type { i32(%"java/lang/Comparable"*, %"java/lang/Object")* }
%"java/lang/System_vtable_type" = type {  }

@"InterfaceCalls_java/lang/Comparable_vtable" = global %"java/lang/Comparable_vtable_type" {
  i32(%"java/lang/Comparable"*, %"java/lang/Object")* @"InterfaceCalls_compareTo(Ljava/lang/Object;)I"
}
%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
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

@InterfaceCalls_vtable_data = global %InterfaceCalls_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  i32(%InterfaceCalls*, %InterfaceCalls)* @"InterfaceCalls_compareTo(LInterfaceCalls;)I",
  i32(%InterfaceCalls*, %"java/lang/Object")* @"InterfaceCalls_compareTo(Ljava/lang/Object;)I"
}

@typeInfo_types = private global [3 x i32] [i32 10, i32 1, i32 8]
@typeInfo_interfaces = private global [1 x i32] [i32 8]
@typeInfo_interface_tables = private global [1 x ptr] [ptr @"InterfaceCalls_java/lang/Comparable_vtable"]
@typeInfo = private global %java_TypeInfo { i32 3, i32* @typeInfo_types, i32 1, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"InterfaceCalls_<init>(I)V"(%InterfaceCalls* %param.0, i32 %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %InterfaceCalls**
  store %InterfaceCalls* %param.0, %InterfaceCalls** %local.0
  %local.1 = alloca i32*
  store i32 %param.1, i32* %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %value entered scope under name %local.1
  ; Line 4
  %1 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  %3 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %2, i32 0, i32 0
  store %InterfaceCalls_vtable_type* @InterfaceCalls_vtable_data, %InterfaceCalls_vtable_type** %3
  %4 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  %5 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 5
  %6 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  %7 = load i32, i32* %local.1
  %8 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %6, i32 0, i32 2
  store i32 %7, i32* %8
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %value exited scope under name %local.1
  unreachable
}

define void @"InterfaceCalls_main([Ljava/lang/String;)V"(%java_Array* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %java_Array**
  store %java_Array* %param.0, %java_Array** %local.0
  br label %label0
label0:
  ; %args entered scope under name %local.0
  ; Line 9
  %1 = alloca %InterfaceCalls
  call void @"InterfaceCalls_<init>(I)V"(%InterfaceCalls* %1, i32 3)
  %local.1 = alloca ptr
  store %InterfaceCalls* %1, ptr %local.1
  br label %label2
label2:
  ; %first entered scope under name %local.1
  ; Line 10
  %2 = alloca %InterfaceCalls
  call void @"InterfaceCalls_<init>(I)V"(%InterfaceCalls* %2, i32 5)
  %local.2 = alloca ptr
  store %InterfaceCalls* %2, ptr %local.2
  br label %label3
label3:
  ; %second entered scope under name %local.2
  ; Line 12
  %3 = load %InterfaceCalls*, %InterfaceCalls** %local.1
  %4 = load %InterfaceCalls*, %InterfaceCalls** %local.2
  call void @"InterfaceCalls_callInterface(Ljava/lang/Comparable;LInterfaceCalls;)V"(%InterfaceCalls* %3, %InterfaceCalls* %4)
  ; Line 13
  ret void
label1:
  ; %args exited scope under name %local.0
  ; %first exited scope under name %local.1
  ; %second exited scope under name %local.2
  unreachable
}

define void @"InterfaceCalls_callInterface(Ljava/lang/Comparable;LInterfaceCalls;)V"(%"java/lang/Comparable"* %param.0, %InterfaceCalls* %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %"java/lang/Comparable"**
  store %"java/lang/Comparable"* %param.0, %"java/lang/Comparable"** %local.0
  %local.1 = alloca %InterfaceCalls**
  store %InterfaceCalls* %param.1, %InterfaceCalls** %local.1
  ; Type type of first between label0 and label1 is Ljava/lang/Comparable<LInterfaceCalls;>;
  br label %label0
label0:
  ; %first entered scope under name %local.0
  ; %second entered scope under name %local.1
  ; Line 16
  %1 = load %"java/lang/Comparable"*, %"java/lang/Comparable"** %local.0
  %2 = load %InterfaceCalls*, %InterfaceCalls** %local.1
  %3 = call ptr @type_interface_vtable(ptr %1, i32 8)
  %4 = getelementptr inbounds %"java/lang/Comparable_vtable_type", %"java/lang/Comparable_vtable_type"* %3, i32 0, i32 0
  %5 = load i32(%"java/lang/Comparable"*, %"java/lang/Object")*, i32(%"java/lang/Comparable"*, %"java/lang/Object")** %4
  %6 = call i32 %5(%"java/lang/Comparable"* %1, %InterfaceCalls* %2)
  %7 = icmp sge i32 %6, 0
  br i1 %7, label %label2, label %label3
label3:
  ; Line 17
  call void @"java/lang/System_exit(I)V"(i32 2)
  br label %label4
label2:
  ; Line 19
  call void @"java/lang/System_exit(I)V"(i32 1)
  br label %label4
label4:
  ; Line 21
  ret void
label1:
  ; %first exited scope under name %local.0
  ; %second exited scope under name %local.1
  unreachable
}

define i32 @"InterfaceCalls_compareTo(LInterfaceCalls;)I"(%InterfaceCalls* %param.0, %InterfaceCalls* %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %InterfaceCalls**
  store %InterfaceCalls* %param.0, %InterfaceCalls** %local.0
  %local.1 = alloca %InterfaceCalls**
  store %InterfaceCalls* %param.1, %InterfaceCalls** %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %o entered scope under name %local.1
  ; Line 25
  %1 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  %2 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %1, i32 0, i32 2
  %3 = load i32, i32* %2
  %4 = load %InterfaceCalls*, %InterfaceCalls** %local.1
  %5 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %4, i32 0, i32 2
  %6 = load i32, i32* %5
  %7 = sub i32 %3, %6
  ret i32 %7
label1:
  ; %this exited scope under name %local.0
  ; %o exited scope under name %local.1
  unreachable
}

define i32 @"InterfaceCalls_compareTo(Ljava/lang/Object;)I"(%InterfaceCalls* %param.0, %"java/lang/Object"* %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %InterfaceCalls**
  store %InterfaceCalls* %param.0, %InterfaceCalls** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %InterfaceCalls*, %InterfaceCalls** %local.0
  %local.1 = alloca %"java/lang/Object"**
  store %"java/lang/Object"* %param.1, %"java/lang/Object"** %local.1
  %2 = load %"java/lang/Object"*, %"java/lang/Object"** %local.1
  %3 = call i1 @instanceof(ptr %2, i32 10)
  br i1 %3, label %label2, label %label3
label3:
  call void @__cxa_throw(ptr null, ptr null, ptr null)
  unreachable
label2:
  %4 = getelementptr inbounds %InterfaceCalls, %InterfaceCalls* %1, i32 0, i32 0
  %5 = load %InterfaceCalls_vtable_type*, %InterfaceCalls_vtable_type** %4
  %6 = getelementptr inbounds %InterfaceCalls_vtable_type, %InterfaceCalls_vtable_type* %5, i32 0, i32 3
  %7 = load i32(%InterfaceCalls*, %InterfaceCalls)*, i32(%InterfaceCalls*, %InterfaceCalls)** %6
  %8 = call i32 %7(%InterfaceCalls* %1, %"java/lang/Object"* %2)
  ret i32 %8
label1:
  ; %this exited scope under name %local.0
  unreachable
}
