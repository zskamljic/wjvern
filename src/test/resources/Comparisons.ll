%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%Comparisons_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Comparisons = type { %Comparisons_vtable_type* }

declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@Comparisons_vtable_data = global %Comparisons_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"Comparisons_<init>()V"(%Comparisons* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %Comparisons, %Comparisons* %local.0, i32 0, i32 0
  store %Comparisons_vtable_type* @Comparisons_vtable_data, %Comparisons_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
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
  %3 = icmp ne ptr %local.0, %local.0
  br i1 %3, label %label3, label %not_label3
not_label3:
  ; Line 6
  call void @printOk(i32 0)
  br label %label3
label3:
  ; Line 8
  %4 = icmp eq ptr %local.0, %local.1
  br i1 %4, label %label4, label %not_label4
not_label4:
  ; Line 9
  call void @printOk(i32 1)
  br label %label4
label4:
  ; Line 11
  call void @compare(i32 1)
  ; Line 12
  call void @compareZero(i32 0)
  ; Line 13
  call void @compareZero(i32 1)
  ; Line 14
  call void @compareLong(i64 0)
  ; Line 15
  call void @compareLong(i64 1)
  ; Line 16
  call void @compareLong(i64 -1)
  ; Line 17
  call void @compareNull(%Comparisons* null)
  ; Line 18
  %5 = load %Comparisons*, %Comparisons** %local.0
  call void @compareNull(%Comparisons* %5)
  ; Line 19
  ret i32 0
label1:
  ; %a exited scope under name %local.0
  ; %b exited scope under name %local.1
  unreachable
}

define void @compare(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %value entered scope under name %local.0
  ; Line 23
  %0 = icmp ne i32 %local.0, 1
  br i1 %0, label %label2, label %not_label2
not_label2:
  ; Line 24
  call void @printOk(i32 2)
  br label %label2
label2:
  ; Line 26
  %1 = icmp eq i32 %local.0, 2
  br i1 %1, label %label3, label %not_label3
not_label3:
  ; Line 27
  call void @printOk(i32 3)
  br label %label3
label3:
  ; Line 29
  %2 = icmp sge i32 %local.0, 2
  br i1 %2, label %label4, label %not_label4
not_label4:
  ; Line 30
  call void @printOk(i32 4)
  br label %label4
label4:
  ; Line 32
  %3 = icmp sle i32 2, %local.0
  br i1 %3, label %label5, label %not_label5
not_label5:
  ; Line 33
  call void @printOk(i32 5)
  br label %label5
label5:
  ; Line 35
  ret void
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define void @compareZero(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %value entered scope under name %local.0
  ; Line 38
  %0 = icmp ne i32 %local.0, 0
  br i1 %0, label %label2, label %not_label2
not_label2:
  ; Line 39
  call void @printOk(i32 6)
  br label %label2
label2:
  ; Line 41
  %1 = icmp eq i32 %local.0, 0
  br i1 %1, label %label3, label %not_label3
not_label3:
  ; Line 42
  call void @printOk(i32 7)
  br label %label3
label3:
  ; Line 44
  %2 = icmp sge i32 %local.0, 0
  br i1 %2, label %label4, label %not_label4
not_label4:
  ; Line 45
  call void @printOk(i32 8)
  br label %label4
label4:
  ; Line 47
  %3 = icmp slt i32 %local.0, 0
  br i1 %3, label %label5, label %not_label5
not_label5:
  ; Line 48
  call void @printOk(i32 9)
  br label %label5
label5:
  ; Line 50
  %4 = icmp sgt i32 %local.0, 0
  br i1 %4, label %label6, label %not_label6
not_label6:
  ; Line 51
  call void @printOk(i32 10)
  br label %label6
label6:
  ; Line 53
  ret void
label1:
  ; %value exited scope under name %local.0
  unreachable
}

define void @compareLong(i64 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %l entered scope under name %local.0
  ; Line 56
  %0 = alloca i32
  %1 = icmp slt i64 %local.0, 0
  br i1 %1, label %label3, label %label4
label3:
  store i32 -1, i32* %0
  br label %label2
label4:
  %2 = icmp sgt i64 %local.0, 0
  br i1 %2, label %label5, label %label6
label5:
  store i32 1, i32* %0
  br label %label2
label6:
  store i32 0, i32* %0
  br label %label2
label2:
  %3 = load i32, i32* %0
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %label7, label %not_label7
not_label7:
  ; Line 57
  call void @printOk(i32 11)
  br label %label7
label7:
  ; Line 59
  %5 = alloca i32
  %6 = icmp slt i64 %local.0, 0
  br i1 %6, label %label9, label %label10
label9:
  store i32 -1, i32* %5
  br label %label8
label10:
  %7 = icmp sgt i64 %local.0, 0
  br i1 %7, label %label11, label %label12
label11:
  store i32 1, i32* %5
  br label %label8
label12:
  store i32 0, i32* %5
  br label %label8
label8:
  %8 = load i32, i32* %5
  %9 = icmp sle i32 %8, 0
  br i1 %9, label %label13, label %not_label13
not_label13:
  ; Line 60
  call void @printOk(i32 12)
  br label %label13
label13:
  ; Line 62
  %10 = alloca i32
  %11 = icmp slt i64 %local.0, 0
  br i1 %11, label %label15, label %label16
label15:
  store i32 -1, i32* %10
  br label %label14
label16:
  %12 = icmp sgt i64 %local.0, 0
  br i1 %12, label %label17, label %label18
label17:
  store i32 1, i32* %10
  br label %label14
label18:
  store i32 0, i32* %10
  br label %label14
label14:
  %13 = load i32, i32* %10
  %14 = icmp sge i32 %13, 0
  br i1 %14, label %label19, label %not_label19
not_label19:
  ; Line 63
  call void @printOk(i32 13)
  br label %label19
label19:
  ; Line 65
  ret void
label1:
  ; %l exited scope under name %local.0
  unreachable
}

define void @compareNull(%Comparisons* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %o entered scope under name %local.0
  ; Line 68
  %0 = icmp ne ptr %local.0, null
  br i1 %0, label %label2, label %not_label2
not_label2:
  ; Line 69
  call void @printOk(i32 14)
  br label %label2
label2:
  ; Line 71
  %1 = icmp eq ptr %local.0, null
  br i1 %1, label %label3, label %not_label3
not_label3:
  ; Line 72
  call void @printOk(i32 15)
  br label %label3
label3:
  ; Line 74
  ret void
label1:
  ; %o exited scope under name %local.0
  unreachable
}

define void @printOk(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %count entered scope under name %local.0
  ; Line 77
  %0 = add i32 48, %local.0
  %1 = trunc i32 %0 to i8
  %local.1 = alloca ptr
  store i8 %1, ptr %local.1
  br label %label2
label2:
  ; %c entered scope under name %local.1
  ; Line 78
  %2 = alloca %java_Array
  %3 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 0
  store i32 5, i32* %3
  %4 = alloca i8, i32 5
  %5 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  store ptr %4, ptr %5
  call void @llvm.memset.p0.i8(ptr %4, i8 0, i64 5, i1 false)
  %6 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %7 = load ptr, ptr %6
  %8 = getelementptr inbounds i8, ptr %7, i32 0
  store i8 79, ptr %8
  %9 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %10 = load ptr, ptr %9
  %11 = getelementptr inbounds i8, ptr %10, i32 1
  store i8 75, ptr %11
  %12 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %13 = load ptr, ptr %12
  %14 = getelementptr inbounds i8, ptr %13, i32 2
  store i8 35, ptr %14
  %15 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %16 = load ptr, ptr %15
  %17 = getelementptr inbounds i8, ptr %16, i32 3
  %18 = load i8, i8* %local.1
  store i8 %18, ptr %17
  %19 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 4
  store i8 0, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %2, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = call i32 @puts(i8* %23)
  ; Line 79
  ret void
label1:
  ; %count exited scope under name %local.0
  ; %c exited scope under name %local.1
  unreachable
}

declare i32 @puts(%java_Array) nounwind
