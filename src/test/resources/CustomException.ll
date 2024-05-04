%"java/lang/Exception" = type { ptr }

declare void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"*)

%CustomException_vtable_type = type { i32(%CustomException*)* }

%CustomException = type { %CustomException_vtable_type*, i32 }

define i32 @"CustomException_getCode()I"(%CustomException* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 27
  %0 = getelementptr inbounds %CustomException, %CustomException* %this, i64 0, i32 1
  %1 = load i32, i32* %0
  ret i32 %1
}

declare i32 @__gxx_personality_v0(...)

@CustomException_vtable_data = global %CustomException_vtable_type {
  i32(%CustomException*)* @"CustomException_getCode()I"
}

define void @"CustomException_<init>(I)V"(%CustomException* %this, i32 %code) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 22
  call void @"java/lang/Exception_<init>()V"(%"java/lang/Exception"* %this)
  %0 = getelementptr inbounds %CustomException, %CustomException* %this, i64 0, i32 0
  store %CustomException_vtable_type* @CustomException_vtable_data, %CustomException_vtable_type** %0
  ; Line 23
  %1 = getelementptr inbounds %CustomException, %CustomException* %this, i64 0, i32 1
  store i32 %code, i32* %1
  ; Line 24
  ret void
}
