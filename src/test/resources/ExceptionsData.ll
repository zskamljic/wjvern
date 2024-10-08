%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%CustomException = type { ptr, ptr, i32 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%ExceptionsData = type { %ExceptionsData_vtable_type*, %java_TypeInfo* }

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
%ExceptionsData_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%CustomException_vtable_type = type { i32(%CustomException*)* }

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

@ExceptionsData_vtable_data = global %ExceptionsData_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 10, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"ExceptionsData_<init>()V"(%ExceptionsData* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %ExceptionsData**
  store %ExceptionsData* %param.0, %ExceptionsData** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %ExceptionsData*, %ExceptionsData** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %ExceptionsData*, %ExceptionsData** %local.0
  %3 = getelementptr inbounds %ExceptionsData, %ExceptionsData* %2, i32 0, i32 0
  store %ExceptionsData_vtable_type* @ExceptionsData_vtable_data, %ExceptionsData_vtable_type** %3
  %4 = load %ExceptionsData*, %ExceptionsData** %local.0
  %5 = getelementptr inbounds %ExceptionsData, %ExceptionsData* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"ExceptionsData_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  call void @"ExceptionsData_nested()V"()
  ; Line 4
  ret i32 0
}

define void @"ExceptionsData_nested()V"() personality ptr @__gxx_personality_v0 {
  %1 = alloca ptr
  br label %label0
label5:
  %2 = landingpad { ptr, i32 } catch ptr @PCustomException_type_info
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %1
  %4 = extractvalue { ptr, i32 } %2, 1
  %5 = call i32 @llvm.eh.typeid.for(ptr @PCustomException_type_info)
  %6 = icmp eq i32 %4, %5
  br i1 %6, label %label2, label %label6
label7:
  %7 = landingpad { ptr, i32 } cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %1
  br label %label6
label6:
  call void @__cxa_throw(ptr %1)
  unreachable
label0:
  ; Line 9
  invoke void @"ExceptionsData_throwing()V"() to label %label8 unwind label %label5
label8:
  br label %label1
label1:
  ; Line 12
  br label %label4
label2:
  %9 = load ptr, ptr %1
  %10 = call ptr @__cxa_begin_catch(ptr %9)
  ; Line 10
  %local.0 = alloca ptr
  store ptr %10, ptr %local.0
  call void @__cxa_end_catch()
  br label %label3
label3:
  ; %e entered scope under name %local.0
  ; Line 11
  %11 = alloca %java_Array
  %12 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 0
  store i32 12, i32* %12
  %13 = alloca i8, i32 12
  %14 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  store ptr %13, ptr %14
  call void @llvm.memset.p0.i8(ptr %13, i8 0, i64 12, i1 false)
  %15 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %16 = load ptr, ptr %15
  %17 = getelementptr inbounds i8, ptr %16, i32 0
  store i8 67, ptr %17
  %18 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %19 = load ptr, ptr %18
  %20 = getelementptr inbounds i8, ptr %19, i32 1
  store i8 97, ptr %20
  %21 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i8, ptr %22, i32 2
  store i8 117, ptr %23
  %24 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = getelementptr inbounds i8, ptr %25, i32 3
  store i8 103, ptr %26
  %27 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %28 = load ptr, ptr %27
  %29 = getelementptr inbounds i8, ptr %28, i32 4
  store i8 104, ptr %29
  %30 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %31 = load ptr, ptr %30
  %32 = getelementptr inbounds i8, ptr %31, i32 5
  store i8 116, ptr %32
  %33 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %34 = load ptr, ptr %33
  %35 = getelementptr inbounds i8, ptr %34, i32 6
  store i8 58, ptr %35
  %36 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %37 = load ptr, ptr %36
  %38 = getelementptr inbounds i8, ptr %37, i32 7
  store i8 32, ptr %38
  %39 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %40 = load ptr, ptr %39
  %41 = getelementptr inbounds i8, ptr %40, i32 8
  store i8 37, ptr %41
  %42 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %43 = load ptr, ptr %42
  %44 = getelementptr inbounds i8, ptr %43, i32 9
  store i8 100, ptr %44
  %45 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %46 = load ptr, ptr %45
  %47 = getelementptr inbounds i8, ptr %46, i32 10
  store i8 10, ptr %47
  %48 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %49 = load ptr, ptr %48
  %50 = getelementptr inbounds i8, ptr %49, i32 11
  store i8 0, ptr %50
  %51 = alloca %java_Array
  %52 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 0
  store i32 1, i32* %52
  %53 = alloca i32, i32 1
  %54 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 1
  store ptr %53, ptr %54
  call void @llvm.memset.p0.i32(ptr %53, i8 0, i64 4, i1 false)
  %55 = load %CustomException*, %CustomException** %local.0
  %56 = getelementptr inbounds %ExceptionsData, %ExceptionsData* %55, i32 0, i32 0
  %57 = load %CustomException_vtable_type*, %CustomException_vtable_type** %56
  %58 = getelementptr inbounds %CustomException_vtable_type, %CustomException_vtable_type* %57, i32 0, i32 0
  %59 = load i32(%CustomException*)*, i32(%CustomException*)** %58
  %60 = call i32 %59(%CustomException* %55)
  %61 = getelementptr inbounds %java_Array, %java_Array* %51, i32 0, i32 1
  %62 = load ptr, ptr %61
  %63 = getelementptr inbounds i32, ptr %62, i32 0
  store i32 %60, ptr %63
  %64 = getelementptr inbounds %java_Array, ptr %51, i32 0, i32 1
  %65 = load ptr, ptr %64
  %66 = getelementptr inbounds %java_Array, ptr %65, i32 0
  %67 = load i32, i32* %66
  %68 = getelementptr inbounds %java_Array, %java_Array* %11, i32 0, i32 1
  %69 = load ptr, ptr %68
  %70 = call i32(i8*,...) @printf(i8* %69, i32 %67)
  br label %label4
label4:
  ; %e exited scope under name %local.0
  ; Line 13
  ret void
}

define void @"ExceptionsData_throwing()V"() personality ptr @__gxx_personality_v0 {
  ; Line 16
  %1 = alloca %CustomException
  call void @"CustomException_<init>(I)V"(%CustomException* %1, i32 5)
  %2 = call ptr @__cxa_allocate_exception(i64 8)
  store %CustomException* %1, ptr %2
  call void @__cxa_throw(%CustomException* %2, ptr @PCustomException_type_info, ptr null)
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
