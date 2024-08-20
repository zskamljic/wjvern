%"java/lang/Exception" = type { ptr }
%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%CustomException = type { %CustomException_vtable_type*, i32 }
declare void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*)

%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%CustomException_vtable_type = type { i32(%CustomException*)* }

define i32 @"CustomException_getCode()I"(%CustomException* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 27
  %0 = getelementptr inbounds %CustomException, %CustomException* %local.0, i32 0, i32 1
  %1 = load i32, i32* %0
  ret i32 %1
label1:
  ; %this exited scope under name %local.0
  unreachable
}

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@CustomException_vtable_data = global %CustomException_vtable_type {
  i32(%CustomException*)* @"CustomException_getCode()I"
}

define void @"CustomException_<init>(I)V"(%CustomException* %local.0, i32 %local.1) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; %code entered scope under name %local.1
  ; Line 22
  call void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"* %local.0)
  %0 = getelementptr inbounds %CustomException, %CustomException* %local.0, i32 0, i32 0
  store %CustomException_vtable_type* @CustomException_vtable_data, %CustomException_vtable_type** %0
  ; Line 23
  %1 = getelementptr inbounds %CustomException, %CustomException* %local.0, i32 0, i32 1
  store i32 %local.1, i32* %1
  ; Line 24
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %code exited scope under name %local.1
  unreachable
}
