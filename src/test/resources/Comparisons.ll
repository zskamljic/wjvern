%"java/lang/Object" = type { ptr, ptr }
%"java/lang/invoke/MethodHandles$Lookup" = type opaque
%"java/lang/String" = type { ptr, ptr, ptr, i8, i32, i1 }
%java_Array = type { i32, ptr }
%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%Comparisons = type { %Comparisons_vtable_type*, %java_TypeInfo* }

declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object"*)
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, %java_Array(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)*, %"java/lang/Object"(%"java/lang/String"*, %"java/lang/invoke/MethodHandles$Lookup"*)* }
%Comparisons_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object"*)*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
declare i32 @__gxx_personality_v0(...)
declare i1 @instanceof(ptr,i32)
declare ptr @type_interface_vtable(ptr,i32)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Comparisons_vtable_data = global %Comparisons_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object"*)* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

@typeInfo_types = private global [2 x i32] [i32 13, i32 1]
@typeInfo_interfaces = private global [0 x i32] []
@typeInfo_interface_tables = private global [0 x ptr] []
@typeInfo = private global %java_TypeInfo { i32 2, i32* @typeInfo_types, i32 0, i32* @typeInfo_interfaces, ptr @typeInfo_interface_tables }

define void @"Comparisons_<init>()V"(%Comparisons* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Comparisons**
  store %Comparisons* %param.0, %Comparisons** %local.0
  br label %label0
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  %1 = load %Comparisons*, %Comparisons** %local.0
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %1)
  %2 = load %Comparisons*, %Comparisons** %local.0
  %3 = getelementptr inbounds %Comparisons, %Comparisons* %2, i32 0, i32 0
  store %Comparisons_vtable_type* @Comparisons_vtable_data, %Comparisons_vtable_type** %3
  %4 = load %Comparisons*, %Comparisons** %local.0
  %5 = getelementptr inbounds %Comparisons, %Comparisons* %4, i32 0, i32 1
  store %java_TypeInfo* @typeInfo, %java_TypeInfo** %5
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"Comparisons_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %Comparisons
  call void @"Comparisons_<init>()V"(%Comparisons* %1)
  %local.0 = alloca ptr
  store %Comparisons* %1, ptr %local.0
  br label %label0
label0:
  ; %a entered scope under name %local.0
  ; Line 4
  %2 = alloca %Comparisons
  call void @"Comparisons_<init>()V"(%Comparisons* %2)
  %local.1 = alloca ptr
  store %Comparisons* %2, ptr %local.1
  br label %label2
label2:
  ; %b entered scope under name %local.1
  ; Line 5
  %3 = load %Comparisons*, %Comparisons** %local.0
  %4 = load %Comparisons*, %Comparisons** %local.0
  %5 = icmp ne ptr %3, %4
  br i1 %5, label %label3, label %label4
label4:
  ; Line 6
  call void @"Comparisons_printOk(I)V"(i32 0)
  br label %label3
label3:
  ; Line 8
  %6 = load %Comparisons*, %Comparisons** %local.0
  %7 = load %Comparisons*, %Comparisons** %local.1
  %8 = icmp eq ptr %6, %7
  br i1 %8, label %label5, label %label6
label6:
  ; Line 9
  call void @"Comparisons_printOk(I)V"(i32 1)
  br label %label5
label5:
  ; Line 11
  call void @"Comparisons_compare(I)V"(i32 1)
  ; Line 12
  call void @"Comparisons_compareZero(I)V"(i32 0)
  ; Line 13
  call void @"Comparisons_compareZero(I)V"(i32 1)
  ; Line 14
  call void @"Comparisons_compareLong(J)V"(i64 0)
  ; Line 15
  call void @"Comparisons_compareLong(J)V"(i64 1)
  ; Line 16
  call void @"Comparisons_compareLong(J)V"(i64 -1)
  ; Line 17
  call void @"Comparisons_compareNull(LComparisons;)V"(%Comparisons* null)
  ; Line 18
  %9 = load %Comparisons*, %Comparisons** %local.0
  call void @"Comparisons_compareNull(LComparisons;)V"(%Comparisons* %9)
  ; Line 19
  ret i32 0
label1:
  ; %a exited scope under name %local.0
  ; %b exited scope under name %local.1
  unreachable
}

define void @"Comparisons_compare(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 23
  %1 = load i32, i32* %local.0
  %2 = icmp ne i32 %1, 1
  br i1 %2, label %label2, label %label3
label3:
  ; Line 24
  call void @"Comparisons_printOk(I)V"(i32 2)
  br label %label2
label2:
  ; Line 26
  %3 = load i32, i32* %local.0
  %4 = icmp eq i32 %3, 2
  br i1 %4, label %label4, label %label5
label5:
  ; Line 27
  call void @"Comparisons_printOk(I)V"(i32 3)
  br label %label4
label4:
  ; Line 29
  %5 = load i32, i32* %local.0
  %6 = icmp sge i32 %5, 2
  br i1 %6, label %label6, label %label7
label7:
  ; Line 30
  call void @"Comparisons_printOk(I)V"(i32 4)
  br label %label6
label6:
  ; Line 32
  %7 = load i32, i32* %local.0
  %8 = icmp sle i32 2, %7
  br i1 %8, label %label8, label %label9
label9:
  ; Line 33
  call void @"Comparisons_printOk(I)V"(i32 5)
  br label %label8
label8:
  ; Line 35
  ret void
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define void @"Comparisons_compareZero(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %value entered scope under name %local.0
  ; Line 38
  %1 = load i32, i32* %local.0
  %2 = icmp ne i32 %1, 0
  br i1 %2, label %label2, label %label3
label3:
  ; Line 39
  call void @"Comparisons_printOk(I)V"(i32 6)
  br label %label2
label2:
  ; Line 41
  %3 = load i32, i32* %local.0
  %4 = icmp eq i32 %3, 0
  br i1 %4, label %label4, label %label5
label5:
  ; Line 42
  call void @"Comparisons_printOk(I)V"(i32 7)
  br label %label4
label4:
  ; Line 44
  %5 = load i32, i32* %local.0
  %6 = icmp sge i32 %5, 0
  br i1 %6, label %label6, label %label7
label7:
  ; Line 45
  call void @"Comparisons_printOk(I)V"(i32 8)
  br label %label6
label6:
  ; Line 47
  %7 = load i32, i32* %local.0
  %8 = icmp slt i32 %7, 0
  br i1 %8, label %label8, label %label9
label9:
  ; Line 48
  call void @"Comparisons_printOk(I)V"(i32 9)
  br label %label8
label8:
  ; Line 50
  %9 = load i32, i32* %local.0
  %10 = icmp sgt i32 %9, 0
  br i1 %10, label %label10, label %label11
label11:
  ; Line 51
  call void @"Comparisons_printOk(I)V"(i32 10)
  br label %label10
label10:
  ; Line 53
  ret void
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define void @"Comparisons_compareLong(J)V"(i64 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i64*
  store i64 %param.0, i64* %local.0
  br label %label0
label0:
  ; %l entered scope under name %local.0
  ; Line 56
  %1 = load i64, i64* %local.0
  %2 = alloca i32
  %3 = icmp slt i64 %1, 0
  br i1 %3, label %label3, label %label4
label3:
  store i32 -1, i32* %2
  br label %label2
label4:
  %4 = icmp sgt i64 %1, 0
  br i1 %4, label %label5, label %label6
label5:
  store i32 1, i32* %2
  br label %label2
label6:
  store i32 0, i32* %2
  br label %label2
label2:
  %5 = load i32, i32* %2
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %label7, label %label8
label8:
  ; Line 57
  call void @"Comparisons_printOk(I)V"(i32 11)
  br label %label7
label7:
  ; Line 59
  %7 = load i64, i64* %local.0
  %8 = alloca i32
  %9 = icmp slt i64 %7, 0
  br i1 %9, label %label10, label %label11
label10:
  store i32 -1, i32* %8
  br label %label9
label11:
  %10 = icmp sgt i64 %7, 0
  br i1 %10, label %label12, label %label13
label12:
  store i32 1, i32* %8
  br label %label9
label13:
  store i32 0, i32* %8
  br label %label9
label9:
  %11 = load i32, i32* %8
  %12 = icmp sle i32 %11, 0
  br i1 %12, label %label14, label %label15
label15:
  ; Line 60
  call void @"Comparisons_printOk(I)V"(i32 12)
  br label %label14
label14:
  ; Line 62
  %13 = load i64, i64* %local.0
  %14 = alloca i32
  %15 = icmp slt i64 %13, 0
  br i1 %15, label %label17, label %label18
label17:
  store i32 -1, i32* %14
  br label %label16
label18:
  %16 = icmp sgt i64 %13, 0
  br i1 %16, label %label19, label %label20
label19:
  store i32 1, i32* %14
  br label %label16
label20:
  store i32 0, i32* %14
  br label %label16
label16:
  %17 = load i32, i32* %14
  %18 = icmp sge i32 %17, 0
  br i1 %18, label %label21, label %label22
label22:
  ; Line 63
  call void @"Comparisons_printOk(I)V"(i32 13)
  br label %label21
label21:
  ; Line 65
  ret void
label1:
  ; %l exited scope under name %local.0
  unreachable
}

define void @"Comparisons_compareNull(LComparisons;)V"(%Comparisons* %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca %Comparisons**
  store %Comparisons* %param.0, %Comparisons** %local.0
  br label %label0
label0:
  ; %o entered scope under name %local.0
  ; Line 68
  %1 = load %Comparisons*, %Comparisons** %local.0
  %2 = icmp ne ptr %1, null
  br i1 %2, label %label2, label %label3
label3:
  ; Line 69
  call void @"Comparisons_printOk(I)V"(i32 14)
  br label %label2
label2:
  ; Line 71
  %3 = load %Comparisons*, %Comparisons** %local.0
  %4 = icmp eq ptr %3, null
  br i1 %4, label %label4, label %label5
label5:
  ; Line 72
  call void @"Comparisons_printOk(I)V"(i32 15)
  br label %label4
label4:
  ; Line 74
  ret void
label1:
  ; %o exited scope under name %local.0
  unreachable
}

define void @"Comparisons_printOk(I)V"(i32 %param.0) personality ptr @__gxx_personality_v0 {
  %local.0 = alloca i32*
  store i32 %param.0, i32* %local.0
  br label %label0
label0:
  ; %count entered scope under name %local.0
  ; Line 77
  %1 = load i32, i32* %local.0
  %2 = add i32 48, %1
  %3 = trunc i32 %2 to i8
  %local.1 = alloca ptr
  store i8 %3, ptr %local.1
  br label %label2
label2:
  ; %c entered scope under name %local.1
  ; Line 78
  %4 = alloca %java_Array
  %5 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 0
  store i32 5, i32* %5
  %6 = alloca i8, i32 5
  %7 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  store ptr %6, ptr %7
  call void @llvm.memset.p0.i8(ptr %6, i8 0, i64 5, i1 false)
  %8 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %9 = load ptr, ptr %8
  %10 = getelementptr inbounds i8, ptr %9, i32 0
  store i8 79, ptr %10
  %11 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = getelementptr inbounds i8, ptr %12, i32 1
  store i8 75, ptr %13
  %14 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %15 = load ptr, ptr %14
  %16 = getelementptr inbounds i8, ptr %15, i32 2
  store i8 35, ptr %16
  %17 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %18 = load ptr, ptr %17
  %19 = getelementptr inbounds i8, ptr %18, i32 3
  %20 = load i8, i8* %local.1
  store i8 %20, ptr %19
  %21 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i8, ptr %22, i32 4
  store i8 0, ptr %23
  %24 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = call i32 @puts(i8* %25)
  ; Line 79
  ret void
label1:
  ; %count exited scope under name %local.0
  ; %c exited scope under name %local.1
  unreachable
}

declare i32 @puts(ptr) nounwind
