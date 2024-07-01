%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%ForEach_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%ForEach = type { %ForEach_vtable_type* }

declare i32 @__gxx_personality_v0(...)

@ForEach_vtable_data = global %ForEach_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ForEach_<init>()V"(%ForEach* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %ForEach, %ForEach* %local.0, i32 0, i32 0
  store %ForEach_vtable_type* @ForEach_vtable_data, %ForEach_vtable_type** %0
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 3
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 3, i32* %2
  %3 = alloca i32, i32 3
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  %local.0 = alloca ptr
  store %java_Array* %1, ptr %local.0
  br label %label2
label2:
  ; %array entered scope under name %local.0
  ; Line 5
  %local.1 = alloca ptr
  store %java_Array* %local.0, ptr %local.1
  %5 = load %java_Array*, %java_Array** %local.1
  %6 = getelementptr inbounds %java_Array, %java_Array* %5, i32 0, i32 0
  %7 = load i32, ptr %6
  %local.2 = alloca ptr
  store i32 %7, ptr %local.2
  %local.3 = alloca ptr
  store i32 0, ptr %local.3
  br label %label4
label4:
  %8 = load i32, i32* %local.2
  %9 = load i32, i32* %local.3
  %10 = icmp sge i32 %9, %8
  br i1 %10, label %label5, label %not_label5
not_label5:
  %11 = load i32, i32* %local.3
  %12 = load %java_Array*, %java_Array** %local.1
  %13 = getelementptr inbounds %java_Array, %java_Array* %12, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i32, ptr %14, i32 %11
  %16 = load i32, ptr %15
  %local.4 = alloca ptr
  store i32 %16, ptr %local.4
  br label %label0
label0:
  ; %i entered scope under name %local.4
  ; Line 6
  %17 = load i32, i32* %local.4
  call void @print(i32 %17)
  br label %label1
label1:
  ; %i exited scope under name %local.4
  ; Line 5
  %18 = load i32, i32* %local.3
  %19 = add i32 %18, 1
  store i32 %19, i32* %local.3
  br label %label4
label5:
  ; Line 9
  ret i32 0
label3:
  ; %array exited scope under name %local.0
  unreachable
}

define void @print(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %number entered scope under name %local.0
  ; Line 13
  %0 = alloca %java_Array
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  store i32 4, i32* %1
  %2 = alloca i8, i32 4
  %3 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  store ptr %2, ptr %3
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
  %local.1 = alloca ptr
  store %java_Array* %0, ptr %local.1
  br label %label2
label2:
  ; %pattern entered scope under name %local.1
  ; Line 14
  %16 = alloca %java_Array
  %17 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 0
  store i32 1, i32* %17
  %18 = alloca i32, i32 1
  %19 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  store ptr %18, ptr %19
  %20 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  %21 = load ptr, ptr %20
  %22 = getelementptr inbounds i32, ptr %21, i32 0
  store i32 %local.0, ptr %22
  %23 = getelementptr inbounds %java_Array, ptr %16, i32 0, i32 1
  %24 = load ptr, ptr %23
  %25 = getelementptr inbounds %java_Array, ptr %24, i32 0
  %26 = load i32, i32* %25
  %27 = load %java_Array*, %java_Array* %local.1
  %28 = getelementptr inbounds %java_Array, %java_Array* %27, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = call i32 @printf(ptr %29, i32 %26)
  ; Line 15
  ret void
label1:
  ; %number exited scope under name %local.0
  ; %pattern exited scope under name %local.1
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
