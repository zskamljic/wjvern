%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%"java/lang/System" = type opaque
%java_Array = type { i32, ptr }
%StandardMain = type { %StandardMain_vtable_type* }
declare void @"java/lang/System_exit(I)V"(i32)
declare %java_Array @"java/lang/String_getBytes()[B"(%"java/lang/String"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%StandardMain_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@StandardMain_vtable_data = global %StandardMain_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"StandardMain_<init>()V"(%StandardMain* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %StandardMain, %StandardMain* %local.0, i32 0, i32 0
  store %StandardMain_vtable_type* @StandardMain_vtable_data, %StandardMain_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"StandardMain_main([Ljava/lang/String;)V"(%java_Array* %local.0) personality ptr @__gxx_personality_v0 {
label2:
  ; %args entered scope under name %local.0
  ; Line 3
  %local.1 = alloca ptr
  store %java_Array* %local.0, ptr %local.1
  %0 = load %java_Array*, %java_Array** %local.1
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  %2 = load i32, ptr %1
  %local.2 = alloca ptr
  store i32 %2, ptr %local.2
  %local.3 = alloca ptr
  store i32 0, ptr %local.3
  br label %label4
label4:
  %3 = load i32, i32* %local.2
  %4 = load i32, i32* %local.3
  %5 = icmp sge i32 %4, %3
  br i1 %5, label %label5, label %label6
label6:
  %6 = load i32, i32* %local.3
  %7 = load %java_Array*, %java_Array** %local.1
  %8 = getelementptr inbounds %java_Array, %java_Array* %7, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds %"java/lang/String", ptr %9, i32 %6
  %11 = load %"java/lang/String"*, ptr %10
  %local.4 = alloca ptr
  store %"java/lang/String"* %11, ptr %local.4
  br label %label0
label0:
  ; %arg entered scope under name %local.4
  ; Line 4
  %12 = load %"java/lang/String"*, %"java/lang/String"** %local.4
  %13 = alloca %java_Array
  call void @"java/lang/String_getBytes()[B"(ptr sret(%java_Array*) %13, %"java/lang/String"* %12)
  %14 = getelementptr inbounds %java_Array, %java_Array* %13, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = call i32 @puts(i8* %15)
  br label %label1
label1:
  ; %arg exited scope under name %local.4
  ; Line 3
  %17 = load i32, i32* %local.3
  %18 = add i32 %17, 1
  store i32 %18, i32* %local.3
  br label %label4
label5:
  ; Line 7
  %19 = getelementptr inbounds %java_Array, %java_Array* %local.0, i32 0, i32 0
  %20 = load i32, ptr %19
  call void @"java/lang/System_exit(I)V"(i32 %20)
  ; Line 8
  ret void
label3:
  ; %args exited scope under name %local.0
  unreachable
}

declare i32 @puts(%java_Array) nounwind
