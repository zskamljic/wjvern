%"java/lang/Object" = type { ptr }
%CustomException = type { ptr, i32 }
%"java/lang/Throwable" = type opaque

declare void @"CustomException_<init>(I)V"(%CustomException*, i32)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare i32 @"CustomException_getCode()I"(%CustomException*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%Exceptions_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

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
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Exceptions_<init>()V"(%Exceptions* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
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
  %11 = load %CustomException*, ptr %local.0
  %e = bitcast ptr %11 to %CustomException*
  ; Line 6
  %12 = getelementptr inbounds %Exceptions, %Exceptions* %e, i64 0, i32 0
  %13 = load %Exceptions_vtable_type*, %Exceptions_vtable_type** %12
  %14 = getelementptr inbounds %Exceptions_vtable_type, %Exceptions_vtable_type* %13, i64 0, i32 0
  %15 = load i32(%CustomException*)*, i32(%CustomException*)** %14
  %16 = call i32 %15(%CustomException* %e)
  %local.1 = alloca ptr
  store i32 %16, ptr %local.1
  br label %label2
label2:
  ; Line 8
  call void @print()
  ; Line 6
  %17 = load i32, ptr %local.1
  ret i32 %17
label3:
  %18 = load ptr, ptr %1
  %19 = call ptr @__cxa_begin_catch(ptr %18)
  ; Line 8
  %local.2 = alloca ptr
  store ptr %19, ptr %local.2
  call void @print()
  ; Line 9
  %20 = load ptr, ptr %local.2
  call void @__cxa_throw(ptr %20, ptr null, ptr null)
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
