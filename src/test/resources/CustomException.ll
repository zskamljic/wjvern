%"java/lang/Exception" = type { ptr, ptr }
%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%CustomException = type { %CustomException_vtable_type*, %java_TypeInfo*, i32 }

declare void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*)
%"java/lang/Exception_vtable_type" = type {  }
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

@CustomException_vtable_data = global %CustomException_vtable_type {
  i32(%CustomException*)* @"CustomException_getCode()I"
}

@typeInfo_types = private global [1 x i32] [i32 10]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 1, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"CustomException_<init>(I)V"(%CustomException* %param.0, i32 %param.1) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %CustomException**
  store %CustomException* %param.0, %CustomException** %local.0
  %local.1 = alloca i32*
  store i32 %param.1, i32* %local.1
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; %code entered scope under name %local.1
  ; Line 22
  %1 = load %CustomException*, %CustomException** %local.0
  call void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"* %1)
  %2 = load %CustomException*, %CustomException** %local.0
  %3 = getelementptr inbounds %CustomException, %CustomException* %2, i32 0, i32 0
  store %CustomException_vtable_type* @CustomException_vtable_data, %CustomException_vtable_type** %3
  %4 = load %CustomException*, %CustomException** %local.0
  %5 = getelementptr inbounds %CustomException, %CustomException* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ; Line 23
  %6 = load %CustomException*, %CustomException** %local.0
  %7 = load i32, i32* %local.1
  %8 = getelementptr inbounds %CustomException, %CustomException* %6, i32 0, i32 2
  store i32 %7, i32* %8
  ; Line 24
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %code exited scope under name %local.1
  unreachable
}

define i32 @"CustomException_getCode()I"(%CustomException* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %CustomException**
  store %CustomException* %param.0, %CustomException** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 27
  %1 = load %CustomException*, %CustomException** %local.0
  %2 = getelementptr inbounds %CustomException, %CustomException* %1, i32 0, i32 2
  %3 = load i32, i32* %2
  ret i32 %3
label1:
  ; %this exited scope under name %local.0
  unreachable
}
