%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%"java/lang/System" = type opaque
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%StandardMain = type { %StandardMain_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/System_exit(I)V"(i32)
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare void @"java/lang/String_getBytes()[B"(ptr, %"java/lang/String"*)
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup")* }
%StandardMain_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/System_vtable_type" = type {  }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@StandardMain_vtable_data = global %StandardMain_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"StandardMain_<init>()V"(%StandardMain* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %StandardMain**
  store %StandardMain* %param.0, %StandardMain** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %StandardMain*, %StandardMain** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %StandardMain*, %StandardMain** %local.0
  %3 = getelementptr inbounds %StandardMain, %StandardMain* %2, i32 0, i32 0
  store %StandardMain_vtable_type* @StandardMain_vtable_data, %StandardMain_vtable_type** %3
  %4 = load %StandardMain*, %StandardMain** %local.0
  %5 = getelementptr inbounds %StandardMain, %StandardMain* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"StandardMain_main([Ljava/lang/String;)V"(%java_Array* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %java_Array**
  store %java_Array* %param.0, %java_Array** %local.0
  br label %label2
label2:
  ; %args entered scope under name %local.0
  ; Line 3
  %1 = load %java_Array*, %java_Array** %local.0
  %local.1 = alloca ptr
  store %java_Array* %1, ptr %local.1
  %2 = load %java_Array*, %java_Array** %local.1
  %3 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 0
  %4 = load i32, ptr %3
  %local.2 = alloca ptr
  store i32 %4, ptr %local.2
  %local.3 = alloca ptr
  store i32 0, ptr %local.3
  br label %label4
label4:
  %5 = load i32, i32* %local.2
  %6 = load i32, i32* %local.3
  %7 = icmp sge i32 %6, %5
  br i1 %7, label %label5, label %label6
label6:
  %8 = load i32, i32* %local.3
  %9 = load %java_Array*, %java_Array** %local.1
  %10 = getelementptr inbounds %java_Array, %java_Array* %9, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds %"java/lang/String", ptr %11, i32 %8
  %13 = load %"java/lang/String"*, ptr %12
  %local.4 = alloca ptr
  store %"java/lang/String"* %13, ptr %local.4
  br label %label0
label0:
  ; %arg entered scope under name %local.4
  ; Line 4
  %14 = load %"java/lang/String"*, %"java/lang/String"** %local.4
  %15 = alloca %java_Array
  call void @"java/lang/String_getBytes()[B"(ptr sret(%java_Array*) %15, %"java/lang/String"* %14)
  %16 = getelementptr inbounds %java_Array, %java_Array* %15, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = call i32 @puts(i8* %17)
  br label %label1
label1:
  ; %arg exited scope under name %local.4
  ; Line 3
  %19 = load i32, i32* %local.3
  %20 = add i32 %19, 1
  store i32 %20, i32* %local.3
  br label %label4
label5:
  ; Line 7
  %21 = load %java_Array*, %java_Array** %local.0
  %22 = getelementptr inbounds %java_Array, %java_Array* %21, i32 0, i32 0
  %23 = load i32, ptr %22
  call void @"java/lang/System_exit(I)V"(i32 %23)
  ; Line 8
  ret void
label3:
  ; %args exited scope under name %local.0
  unreachable
}

declare i32 @puts(%java_Array) nounwind
