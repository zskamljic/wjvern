%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%"java/lang/AutoCloseable" = type opaque
%"java/lang/Throwable" = type { ptr, ptr, ptr, ptr, ptr, ptr, i32, ptr }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%TryWithResources = type { %TryWithResources_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object"*)
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Throwable_addSuppressed(Ljava/lang/Throwable;)V"(%"java/lang/Throwable"*, %"java/lang/Throwable")
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)* }
%TryWithResources_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, void(%TryWithResources*)*, void(%TryWithResources*)* }
%"java/lang/AutoCloseable_vtable_type" = type {  }
%"java/lang/Throwable_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, %"java/lang/String"(%"java/lang/Throwable"*)*, %"java/lang/String"(%"java/lang/Throwable"*)*, %"java/lang/Throwable"(%"java/lang/Throwable"*)* }

%"java/util/stream/IntStream" = type opaque
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

@"java/lang/Throwable_type_string" = constant [22 x i8] c"19java/lang/Throwable\00"
@"Pjava/lang/Throwable_type_string" = constant [23 x i8] c"P19java/lang/Throwable\00"
@"java/lang/Throwable_type_info" = constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), ptr @"java/lang/Throwable_type_string" }
@"Pjava/lang/Throwable_type_info" = constant { ptr, ptr, i32, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv119__pointer_type_infoE, i64 2), ptr @"Pjava/lang/Throwable_type_string", i32 0, ptr @"java/lang/Throwable_type_info" }

@TryWithResources_vtable_data = global %TryWithResources_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object"*)* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V",
  void(%TryWithResources*)* @"TryWithResources_printWork()V",
  void(%TryWithResources*)* @"TryWithResources_close()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"TryWithResources_<init>()V"(%TryWithResources* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %TryWithResources**
  store %TryWithResources* %param.0, %TryWithResources** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %TryWithResources*, %TryWithResources** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %TryWithResources*, %TryWithResources** %local.0
  %3 = getelementptr inbounds %TryWithResources, %TryWithResources* %2, i32 0, i32 0
  store %TryWithResources_vtable_type* @TryWithResources_vtable_data, %TryWithResources_vtable_type** %3
  %4 = load %TryWithResources*, %TryWithResources** %local.0
  %5 = getelementptr inbounds %TryWithResources, %TryWithResources* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"TryWithResources_main([Ljava/lang/String;)V"(%java_Array* %param.0) personality ptr @__gxx_personality_v0 {
  %1 = alloca ptr
  %local.0 = alloca %java_Array**
  store %java_Array* %param.0, %java_Array** %local.0
  br label %label7
label7:
  ; %args entered scope under name %local.0
  ; Line 3
  %2 = alloca %TryWithResources
  call void @"TryWithResources_<init>()V"(%TryWithResources* %2)
  %local.1 = alloca ptr
  store %TryWithResources* %2, ptr %local.1
  br label %label0
label9:
  %3 = landingpad { ptr, i32 } catch ptr @"Pjava/lang/Throwable_type_info"
  %4 = extractvalue { ptr, i32 } %3, 0
  store ptr %4, ptr %1
  %5 = extractvalue { ptr, i32 } %3, 1
  %6 = call i32 @llvm.eh.typeid.for(ptr @"Pjava/lang/Throwable_type_info")
  %7 = icmp eq i32 %5, %6
  br i1 %7, label %label2, label %label10
label10:
  call void @__cxa_throw(ptr %1, ptr null, ptr null)
  unreachable
label0:
  ; %instance entered scope under name %local.1
  ; Line 4
  %8 = load %TryWithResources*, %TryWithResources** %local.1
  %9 = getelementptr inbounds %TryWithResources, %TryWithResources* %8, i32 0, i32 0
  %10 = load %TryWithResources_vtable_type*, %TryWithResources_vtable_type** %9
  %11 = getelementptr inbounds %TryWithResources_vtable_type, %TryWithResources_vtable_type* %10, i32 0, i32 3
  %12 = load void(%TryWithResources*)*, void(%TryWithResources*)** %11
  invoke void %12(%TryWithResources* %8) to label %label11 unwind label %label9
label11:
  br label %label1
label1:
  ; Line 5
  %13 = load %TryWithResources*, %TryWithResources** %local.1
  %14 = getelementptr inbounds %TryWithResources, %TryWithResources* %13, i32 0, i32 0
  %15 = load %TryWithResources_vtable_type*, %TryWithResources_vtable_type** %14
  %16 = getelementptr inbounds %TryWithResources_vtable_type, %TryWithResources_vtable_type* %15, i32 0, i32 4
  %17 = load void(%TryWithResources*)*, void(%TryWithResources*)** %16
  call void %17(%TryWithResources* %13)
  br label %label6
label2:
  %18 = load ptr, ptr %1
  %19 = call ptr @__cxa_begin_catch(ptr %18)
  call void @__cxa_end_catch()
  ; Line 3
  %local.2 = alloca ptr
  store ptr %19, ptr %local.2
  br label %label3
label12:
  %20 = landingpad { ptr, i32 } catch ptr @"Pjava/lang/Throwable_type_info"
  %21 = extractvalue { ptr, i32 } %20, 0
  store ptr %21, ptr %1
  %22 = extractvalue { ptr, i32 } %20, 1
  %23 = call i32 @llvm.eh.typeid.for(ptr @"Pjava/lang/Throwable_type_info")
  %24 = icmp eq i32 %22, %23
  br i1 %24, label %label5, label %label13
label13:
  call void @__cxa_throw(ptr %1, ptr null, ptr null)
  unreachable
label3:
  %25 = load %TryWithResources*, %TryWithResources** %local.1
  %26 = getelementptr inbounds %TryWithResources, %TryWithResources* %25, i32 0, i32 0
  %27 = load %TryWithResources_vtable_type*, %TryWithResources_vtable_type** %26
  %28 = getelementptr inbounds %TryWithResources_vtable_type, %TryWithResources_vtable_type* %27, i32 0, i32 4
  %29 = load void(%TryWithResources*)*, void(%TryWithResources*)** %28
  invoke void %29(%TryWithResources* %25) to label %label14 unwind label %label12
label14:
  br label %label4
label4:
  br label %label15
label5:
  %30 = load ptr, ptr %1
  %31 = call ptr @__cxa_begin_catch(ptr %30)
  call void @__cxa_end_catch()
  %local.3 = alloca ptr
  store ptr %31, ptr %local.3
  call void @"java/lang/Throwable_addSuppressed(Ljava/lang/Throwable;)V"(%"java/lang/Throwable"* %local.2, ptr %local.3)
  br label %label15
label15:
  %32 = load ptr, ptr %local.2
  call void @__cxa_throw(ptr %32, ptr null, ptr null)
  unreachable
label6:
  ; %instance exited scope under name %local.1
  ; Line 6
  ret void
label8:
  ; %args exited scope under name %local.0
  unreachable
}

define void @"TryWithResources_printWork()V"(%TryWithResources* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %TryWithResources**
  store %TryWithResources* %param.0, %TryWithResources** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 9
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 5, i32* %2
  %3 = alloca i8, i32 5
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 5, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 87, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 111, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 114, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 107, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 4
  store i8 0, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = call i32 @puts(i8* %21)
  ; Line 10
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"TryWithResources_printClose()V"() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 6, i32* %2
  %3 = alloca i8, i32 6
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 6, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 67, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 108, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 111, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 115, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 4
  store i8 101, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i8, ptr %21, i32 5
  store i8 0, ptr %22
  %23 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = call i32 @puts(i8* %24)
  ; Line 14
  ret void
}

declare i32 @puts(ptr) nounwind

define void @"TryWithResources_close()V"(%TryWithResources* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %TryWithResources**
  store %TryWithResources* %param.0, %TryWithResources** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 20
  call void @"TryWithResources_printClose()V"()
  ; Line 21
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}
