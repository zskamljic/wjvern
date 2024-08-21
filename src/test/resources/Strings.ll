%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%Strings = type { %Strings_vtable_type* }
@string.value.7 = private unnamed_addr constant [7 x i8] c"hello\0A\00"
@string.array.7 = private unnamed_addr constant %java_Array { i32 7, ptr @string.value.7 }
@string.7 = private global %"java/lang/String" { ptr null, ptr null, i8 0, i32 0, i1 0 }

declare %java_Array @"java/lang/String_getBytes()[B"(%"java/lang/String"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare i32 @"java/lang/String_length()I"(%"java/lang/String"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%Strings_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

declare void @"java/lang/String_<init>([BB)V"(ptr, ptr, i8) personality ptr @__gxx_personality_v0
define void @"Strings_var_init"() personality ptr @__gxx_personality_v0 {
  invoke void @"java/lang/String_<init>([BB)V"(ptr @string.7, %java_Array* @string.array.7, i8 0) to label %label.0 unwind label %handlerLabel
label.0:
  ret void
handlerLabel:
  %1 = landingpad { ptr, i32 } cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  %3 = extractvalue { ptr, i32 } %1, 1
  %4 = insertvalue { ptr, i32 } poison, ptr %2, 0
  %5 = insertvalue { ptr, i32 } %4, i32 %3, 1
  resume { ptr, i32 } %5
}

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Strings_vtable_data = global %Strings_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Strings_<init>()V"(%Strings* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %Strings, %Strings* %local.0, i32 0, i32 0
  store %Strings_vtable_type* @Strings_vtable_data, %Strings_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Strings_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %local.0 = alloca ptr
  store ptr @string.7, ptr %local.0
  br label %label0
label0:
  ; %string entered scope under name %local.0
  ; Line 4
  %1 = load %"java/lang/String"*, %"java/lang/String"** %local.0
  %2 = alloca %java_Array
  call void @"java/lang/String_getBytes()[B"(ptr sret(%java_Array*) %2, %"java/lang/String"* %1)
  %local.1 = alloca ptr
  store %java_Array* %2, ptr %local.1
  br label %label2
label2:
  ; %bytes entered scope under name %local.1
  ; Line 5
  %3 = load %java_Array*, %java_Array** %local.1
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  %5 = load i32, ptr %4
  call void @"Strings_printInt(I)V"(i32 %5)
  ; Line 6
  %6 = load %java_Array*, %java_Array** %local.1
  %7 = getelementptr inbounds %java_Array, %java_Array* %6, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = call i32 @puts(i8* %8)
  ; Line 7
  %10 = load %"java/lang/String"*, %"java/lang/String"** %local.0
  %11 = getelementptr inbounds %Strings, %Strings* %10, i32 0, i32 0
  %12 = load %"java/lang/String_vtable_type"*, %"java/lang/String_vtable_type"** %11
  %13 = getelementptr inbounds %"java/lang/String_vtable_type", %"java/lang/String_vtable_type"* %12, i32 0, i32 3
  %14 = load i32(%"java/lang/String"*)*, i32(%"java/lang/String"*)** %13
  %15 = call i32 %14(%"java/lang/String"* %10)
  call void @"Strings_printInt(I)V"(i32 %15)
  ; Line 8
  %16 = load %"java/lang/String"*, %"java/lang/String"** %local.0
  %17 = alloca %java_Array
  call void @"java/lang/String_getBytes()[B"(ptr sret(%java_Array*) %17, %"java/lang/String"* %16)
  %18 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %19 = load ptr, ptr %18
  %20 = call i32 @puts(i8* %19)
  ; Line 9
  ret i32 0
label1:
  ; %string exited scope under name %local.0
  ; %bytes exited scope under name %local.1
  unreachable
}

define void @"Strings_printInt(I)V"(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %i entered scope under name %local.0
  ; Line 13
  %0 = alloca %java_Array
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  store i32 4, i32* %1
  %2 = alloca i8, i32 4
  %3 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  store ptr %2, ptr %3
  call void @llvm.memset.p0.i8(ptr %2, i8 0, i64 4, i1 false)
  %4 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %5 = load ptr, ptr %4
  %6 = getelementptr inbounds i8, ptr %5, i32 0
  store i8 37, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 1
  store i8 100, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 2
  store i8 10, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 3
  store i8 0, ptr %15
  %16 = alloca %java_Array
  %17 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 0
  store i32 1, i32* %17
  %18 = alloca i32, i32 1
  %19 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  store ptr %18, ptr %19
  call void @llvm.memset.p0.i32(ptr %18, i8 0, i64 4, i1 false)
  %20 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i32, ptr %21, i32 0
  store i32 %local.0, ptr %22
  %23 = getelementptr inbounds %java_Array, ptr %16, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds %java_Array, ptr %24, i32 0
  %26 = load i32, i32* %25
  %27 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %28 = load ptr, ptr %27
  %29 = call i32(i8*,...) @printf(i8* %28, i32 %26)
  ; Line 14
  ret void
label1:
  ; %i exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind

declare i32 @puts(%java_Array) nounwind
