%"java/lang/Exception" = type { ptr }
%"java/lang/Object" = type { ptr }
%"java/lang/Throwable" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)
declare void @"java/lang/Exception_<init>"(%"java/lang/Exception"*)

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

@_ZTVN10__cxxabiv117__class_type_infoE = external global ptr
@_ZTVN10__cxxabiv119__pointer_type_infoE = external global ptr
@"java/lang/Exception_type_string" = constant [22 x i8] c"19java/lang/Exception\00"
@"Pjava/lang/Exception_type_string" = constant [23 x i8] c"P19java/lang/Exception\00"
@"java/lang/Exception_type_info" = constant { ptr, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv117__class_type_infoE, i64 2), ptr @"java/lang/Exception_type_string" }
@"Pjava/lang/Exception_type_info" = constant { ptr, ptr, i32, ptr } { ptr getelementptr inbounds (ptr, ptr @_ZTVN10__cxxabiv119__pointer_type_infoE, i64 2), ptr @"Pjava/lang/Exception_type_string", i32 0, ptr @"Pjava/lang/Exception_type_info" }

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
  %e = alloca %"java/lang/Exception"
  br label %label0
label0:
  ; Line 4
  %1 = alloca %"java/lang/Exception"
  call void @"java/lang/Exception_<init>"(%"java/lang/Exception"* %1)
  %2 = call ptr @__cxa_allocate_exception(i64 8)
  store %"java/lang/Exception"* %1, ptr %2
  invoke void @__cxa_throw(%"java/lang/Exception"* %2, ptr @"Pjava/lang/Exception_type_info", ptr null) to label %label4 unwind label %label5
label4:
  unreachable
label5:
  %3 = landingpad { ptr, i32 } catch ptr @"Pjava/lang/Exception_type_info"
  %4 = extractvalue { ptr, i32 } %3, 0
  %5 = extractvalue { ptr, i32 } %3, 1
  %6 = call i32 @llvm.eh.typeid.for(ptr @"Pjava/lang/Exception_type_info")
  %7 = icmp eq i32 %5, %6
  br i1 %7, label %label1, label %label3
label1:
  ; Line 5
  store ptr %4, %"java/lang/Exception"* %e
  br label %label6
label6:
  ; Line 6
  %8 = alloca i32
  store i32 1, i32* %8
  br label %label2
label2:
  ; Line 8
  call void @print()
  ; Line 6
  %9 = load i32, i32* %8
  ret i32 %9
label3:
  ; Line 8
  %10 = alloca ptr
  store ptr %4, ptr %10
  call void @print()
  ; Line 9
  call void @__cxa_throw(ptr %10, ptr null, ptr null)
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
