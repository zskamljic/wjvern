%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

declare i1 @"java/lang/Object_equals"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_finalize"(%"java/lang/Object"*)

%Comparisons_vtable_type = type { i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%Comparisons = type { %Comparisons_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@Comparisons_vtable_data = global %Comparisons_vtable_type {
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize"
}

define void @"Comparisons_<init>"(%Comparisons* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Comparisons, %Comparisons* %this, i64 0, i32 0
  store %Comparisons_vtable_type* @Comparisons_vtable_data, %Comparisons_vtable_type** %0
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %Comparisons
  call void @"Comparisons_<init>"(%Comparisons* %1)
  %local.0 = alloca ptr
  store %Comparisons* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %Comparisons*, ptr %local.0
  %a = bitcast ptr %2 to %Comparisons*
  ; Line 4
  %3 = alloca %Comparisons
  call void @"Comparisons_<init>"(%Comparisons* %3)
  %local.1 = alloca ptr
  store %Comparisons* %3, ptr %local.1
  br label %label2
label2:
  %4 = load %Comparisons*, ptr %local.1
  %b = bitcast ptr %4 to %Comparisons*
  ; Line 5
  %5 = icmp ne ptr %a, %a
  br i1 %5, label %label3, label %not_label3
not_label3:
  ; Line 6
  call void @printOk(i32 0)
  br label %label3
label3:
  ; Line 8
  %6 = icmp eq ptr %a, %b
  br i1 %6, label %label4, label %not_label4
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
  ret i32 0
}

define void @compare(i32 %value) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 18
  %0 = icmp ne i32 %value, 1
  br i1 %0, label %label2, label %not_label2
not_label2:
  ; Line 19
  call void @printOk(i32 2)
  br label %label2
label2:
  ; Line 21
  %1 = icmp eq i32 %value, 2
  br i1 %1, label %label3, label %not_label3
not_label3:
  ; Line 22
  call void @printOk(i32 3)
  br label %label3
label3:
  ; Line 24
  %2 = icmp sge i32 %value, 2
  br i1 %2, label %label4, label %not_label4
not_label4:
  ; Line 25
  call void @printOk(i32 4)
  br label %label4
label4:
  ; Line 27
  %3 = icmp sle i32 2, %value
  br i1 %3, label %label5, label %not_label5
not_label5:
  ; Line 28
  call void @printOk(i32 5)
  br label %label5
label5:
  ; Line 30
  ret void
}

define void @compareZero(i32 %value) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 33
  %0 = icmp ne i32 %value, 0
  br i1 %0, label %label2, label %not_label2
not_label2:
  ; Line 34
  call void @printOk(i32 6)
  br label %label2
label2:
  ; Line 36
  %1 = icmp eq i32 %value, 0
  br i1 %1, label %label3, label %not_label3
not_label3:
  ; Line 37
  call void @printOk(i32 7)
  br label %label3
label3:
  ; Line 39
  %2 = icmp sge i32 %value, 0
  br i1 %2, label %label4, label %not_label4
not_label4:
  ; Line 40
  call void @printOk(i32 8)
  br label %label4
label4:
  ; Line 42
  %3 = icmp slt i32 %value, 0
  br i1 %3, label %label5, label %not_label5
not_label5:
  ; Line 43
  call void @printOk(i32 9)
  br label %label5
label5:
  ; Line 45
  %4 = icmp sgt i32 %value, 0
  br i1 %4, label %label6, label %not_label6
not_label6:
  ; Line 46
  call void @printOk(i32 10)
  br label %label6
label6:
  ; Line 48
  ret void
}

define void @printOk(i32 %count) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 51
  %0 = add i32 48, %count
  %local.1 = alloca ptr
  store i32 %0, ptr %local.1
  br label %label2
label2:
  %c = bitcast ptr %local.1 to i8*
  ; Line 52
  %1 = alloca [5 x i8]
  %2 = getelementptr inbounds [5 x i8], ptr %1, i64 0, i32 0
  store i8 79, ptr %2
  %3 = getelementptr inbounds [5 x i8], ptr %1, i64 0, i32 1
  store i8 75, ptr %3
  %4 = getelementptr inbounds [5 x i8], ptr %1, i64 0, i32 2
  store i8 35, ptr %4
  %5 = getelementptr inbounds [5 x i8], ptr %1, i64 0, i32 3
  %6 = load i8, i8* %c
  store i8 %6, ptr %5
  %7 = getelementptr inbounds [5 x i8], ptr %1, i64 0, i32 4
  store i8 0, ptr %7
  %8 = call i32 @puts(ptr %1)
  ; Line 53
  ret void
}

declare i32 @puts(ptr) nounwind
