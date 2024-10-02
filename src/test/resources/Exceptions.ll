%"java/lang/Object" = type { ptr, ptr }
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%CustomException = type { ptr, ptr, i32 }
%"java/lang/Throwable" = type opaque
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%Exceptions = type { %Exceptions_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"CustomException_<init>(I)V"(%CustomException*, i32)
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare i32 @"CustomException_getCode()I"(%CustomException*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Exceptions_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%CustomException_vtable_type = type { i32(%CustomException*)* }
%"java/lang/Throwable_vtable_type" = type {  }

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

@CustomException_type_string = constant [18 x i8] c"15CustomException\00"
@PCustomException_type_string = constant [19 x i8] c"P15CustomException\00"
@CustomException_type_info = constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), ptr @CustomException_type_string }
@PCustomException_type_info = constant { ptr, ptr, i32, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv119__pointer_type_infoE, i64 2), ptr @PCustomException_type_string, i32 0, ptr @CustomException_type_info }

@Exceptions_vtable_data = global %Exceptions_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 2, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"Exceptions_<init>()V"(%Exceptions* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Exceptions**
  store %Exceptions* %param.0, %Exceptions** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Exceptions*, %Exceptions** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Exceptions*, %Exceptions** %local.0
  %3 = getelementptr inbounds %Exceptions, %Exceptions* %2, i32 0, i32 0
  store %Exceptions_vtable_type* @Exceptions_vtable_data, %Exceptions_vtable_type** %3
  %4 = load %Exceptions*, %Exceptions** %local.0
  %5 = getelementptr inbounds %Exceptions, %Exceptions* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Exceptions_main()I"() personality ptr @__gxx_personality_v0 {
  %1 = alloca ptr
  br label %label0
label5:
  %2 = landingpad { ptr, i32 } catch ptr @PCustomException_type_info
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %1
  %4 = extractvalue { ptr, i32 } %2, 1
  %5 = call i32 @llvm.eh.typeid.for(ptr @PCustomException_type_info)
  %6 = icmp eq i32 %4, %5
  br i1 %6, label %label1, label %label3
label0:
  ; Line 4
  %7 = alloca %CustomException
  invoke void @"CustomException_<init>(I)V"(%CustomException* %7, i32 5) to label %label6 unwind label %label5
label6:
  %8 = call ptr @__cxa_allocate_exception(i64 8)
  store %CustomException* %7, ptr %8
  invoke void @__cxa_throw(%CustomException* %8, ptr @PCustomException_type_info, ptr null) to label %label7 unwind label %label5
label7:
  unreachable
label1:
  %9 = load ptr, ptr %1
  %10 = call ptr @__cxa_begin_catch(ptr %9)
  ; Line 5
  %local.0 = alloca ptr
  store ptr %10, ptr %local.0
  call void @__cxa_end_catch()
  br label %label4
label4:
  ; %e entered scope under name %local.0
  ; Line 6
  %11 = load %CustomException*, %CustomException** %local.0
  %12 = getelementptr inbounds %Exceptions, %Exceptions* %11, i32 0, i32 0
  %13 = load %CustomException_vtable_type*, %CustomException_vtable_type** %12
  %14 = getelementptr inbounds %CustomException_vtable_type, %CustomException_vtable_type* %13, i32 0, i32 0
  %15 = load i32(%CustomException*)*, i32(%CustomException*)** %14
  %16 = call i32 %15(%CustomException* %11)
  %local.1 = alloca ptr
  store i32 %16, ptr %local.1
  br label %label2
label2:
  ; Line 8
  call void @"Exceptions_print()V"()
  ; Line 6
  %17 = load i32, i32* %local.1
  ret i32 %17
label3:
  ; %e exited scope under name %local.0
  %18 = load ptr, ptr %1
  %19 = call ptr @__cxa_begin_catch(ptr %18)
  ; Line 8
  %local.2 = alloca ptr
  store ptr %19, ptr %local.2
  call void @"Exceptions_print()V"()
  ; Line 9
  %20 = load ptr, ptr %local.2
  call void @__cxa_throw(ptr %20, ptr null, ptr null)
  unreachable
}

define void @"Exceptions_print()V"() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 7, i32* %2
  %3 = alloca i8, i32 7
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i8(ptr %3, i8 0, i64 7, i1 false)
  %5 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %6 = load ptr, ptr %5
  %7 = getelementptr inbounds i8, ptr %6, i32 0
  store i8 72, ptr %7
  %8 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 1
  store i8 101, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 2
  store i8 108, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 3
  store i8 108, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 4
  store i8 111, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i8, ptr %21, i32 5
  store i8 33, ptr %22
  %23 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds i8, ptr %24, i32 6
  store i8 0, ptr %25
  %26 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  %27 = load ptr, ptr %26
  %28 = call i32 @puts(i8* %27)
  ; Line 14
  ret void
}

declare i32 @puts(%java_Array) nounwind
