%"java/lang/Object" = type { ptr }
%CustomException = type { ptr, i32 }
%java_Array = type { i32, ptr }
declare void @"CustomException_<init>(I)V"(%CustomException*, i32)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare i32 @"CustomException_getCode()I"(%CustomException*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%ExceptionsData_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%ExceptionsData = type { %ExceptionsData_vtable_type* }

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

@ExceptionsData_vtable_data = global %ExceptionsData_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ExceptionsData_<init>()V"(%ExceptionsData* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %ExceptionsData, %ExceptionsData* %this, i32 0, i32 0
  store %ExceptionsData_vtable_type* @ExceptionsData_vtable_data, %ExceptionsData_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  call void @nested()
  ; Line 4
  ret i32 0
}

define void @nested() personality ptr @__gxx_personality_v0 {
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
  invoke void @throwing() to label %label8 unwind label %label5
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
  %11 = load %CustomException*, ptr %local.0
  %e = bitcast ptr %11 to %CustomException*
  ; Line 11
  %12 = alloca %java_Array
  %13 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 0
  store i32 12, i32* %13
  %14 = alloca i8, i32 12
  %15 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  store ptr %14, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 0
  store i8 67, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 1
  store i8 97, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 2
  store i8 117, ptr %24
  %25 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i8, ptr %26, i32 3
  store i8 103, ptr %27
  %28 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = getelementptr inbounds i8, ptr %29, i32 4
  store i8 104, ptr %30
  %31 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %32 = load ptr, ptr %31
  %33 = getelementptr inbounds i8, ptr %32, i32 5
  store i8 116, ptr %33
  %34 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %35 = load ptr, ptr %34
  %36 = getelementptr inbounds i8, ptr %35, i32 6
  store i8 58, ptr %36
  %37 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %38 = load ptr, ptr %37
  %39 = getelementptr inbounds i8, ptr %38, i32 7
  store i8 32, ptr %39
  %40 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %41 = load ptr, ptr %40
  %42 = getelementptr inbounds i8, ptr %41, i32 8
  store i8 37, ptr %42
  %43 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %44 = load ptr, ptr %43
  %45 = getelementptr inbounds i8, ptr %44, i32 9
  store i8 100, ptr %45
  %46 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %47 = load ptr, ptr %46
  %48 = getelementptr inbounds i8, ptr %47, i32 10
  store i8 10, ptr %48
  %49 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %50 = load ptr, ptr %49
  %51 = getelementptr inbounds i8, ptr %50, i32 11
  store i8 0, ptr %51
  %52 = alloca %java_Array
  %53 = getelementptr inbounds %java_Array, %java_Array* %52, i32 0, i32 0
  store i32 1, i32* %53
  %54 = alloca i32, i32 1
  %55 = getelementptr inbounds %java_Array, %java_Array* %52, i32 0, i32 1
  store ptr %54, ptr %55
  %56 = getelementptr inbounds %ExceptionsData, %ExceptionsData* %e, i32 0, i32 0
  %57 = load %ExceptionsData_vtable_type*, %ExceptionsData_vtable_type** %56
  %58 = getelementptr inbounds %ExceptionsData_vtable_type, %ExceptionsData_vtable_type* %57, i32 0, i32 0
  %59 = load i32(%CustomException*)*, i32(%CustomException*)** %58
  %60 = call i32 %59(%CustomException* %e)
  %61 = getelementptr inbounds %java_Array, %java_Array* %52, i32 0, i32 1
  %62 = load ptr, ptr %61
  %63 = getelementptr inbounds i32, ptr %62, i32 0
  store i32 %60, ptr %63
  %64 = getelementptr inbounds %java_Array, ptr %52, i32 0, i32 1
  %65 = load ptr, ptr %64
  %66 = getelementptr inbounds %java_Array, ptr %65, i32 0
  %67 = load i32, i32* %66
  %68 = getelementptr inbounds %java_Array, ptr %12, i32 0, i32 1
  %69 = load ptr, ptr %68
  %70 = call i32 @printf(ptr %69, i32 %67)
  br label %label4
label4:
  ; Line 13
  ret void
}

define void @throwing() personality ptr @__gxx_personality_v0 {
  ; Line 16
  %1 = alloca %CustomException
  call void @"CustomException_<init>(I)V"(%CustomException* %1, i32 5)
  %2 = call ptr @__cxa_allocate_exception(i64 8)
  store %CustomException* %1, ptr %2
  call void @__cxa_throw(%CustomException* %2, ptr @PCustomException_type_info, ptr null)
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
