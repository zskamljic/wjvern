%"java/lang/Object" = type { ptr }
%CustomException = type { ptr, i32 }
%"java/lang/Throwable" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)
declare i32 @CustomException_getCode(%CustomException*)
declare void @"CustomException_<init>"(%CustomException*, i32)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%Exceptions_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Exceptions = type { %Exceptions_vtable_type* }

declare i32 @__gxx_personality_v0(...)

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
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"Exceptions_<init>"(%Exceptions* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Exceptions, %Exceptions* %this, i64 0, i32 0
  store %Exceptions_vtable_type* @Exceptions_vtable_data, %Exceptions_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
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
  invoke void @"CustomException_<init>"(%CustomException* %7, i32 5) to label %label6 unwind label %label5
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
  %11 = load %CustomException*, ptr %local.0
  %e = bitcast ptr %11 to %CustomException*
  ; Line 6
  %12 = call i32 @CustomException_getCode(%CustomException* %e)
  %local.1 = alloca ptr
  store i32 %12, ptr %local.1
  br label %label2
label2:
  ; Line 8
  call void @print()
  ; Line 6
  %13 = load i32, ptr %local.1
  ret i32 %13
label3:
  %14 = load ptr, ptr %1
  %15 = call ptr @__cxa_begin_catch(ptr %14)
  ; Line 8
  %local.2 = alloca ptr
  store ptr %15, ptr %local.2
  call void @print()
  ; Line 9
  %16 = load ptr, ptr %local.2
  call void @__cxa_throw(ptr %16, ptr null, ptr null)
  unreachable
}

define void @print() personality ptr @__gxx_personality_v0 {
  ; Line 13
  %1 = alloca [7 x i8]
  %2 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 0
  store i8 72, ptr %2
  %3 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 1
  store i8 101, ptr %3
  %4 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 2
  store i8 108, ptr %4
  %5 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 3
  store i8 108, ptr %5
  %6 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 4
  store i8 111, ptr %6
  %7 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 5
  store i8 33, ptr %7
  %8 = getelementptr inbounds [7 x i8], ptr %1, i64 0, i32 6
  store i8 0, ptr %8
  %9 = call i32 @puts(ptr %1)
  ; Line 14
  ret void
}

declare i32 @puts(ptr) nounwind
