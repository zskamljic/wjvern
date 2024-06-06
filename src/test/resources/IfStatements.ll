%"java/lang/Object" = type { ptr }

declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%IfStatements_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%IfStatements = type { %IfStatements_vtable_type*, i32, i1 }

declare i32 @__gxx_personality_v0(...)

@IfStatements_vtable_data = global %IfStatements_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"IfStatements_<init>()V"(%IfStatements* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 0
  store %IfStatements_vtable_type* @IfStatements_vtable_data, %IfStatements_vtable_type** %0
  ; Line 3
  %1 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  store i1 0, i1* %1
  ret void
}

define void @"IfStatements_doSomething()V"(%IfStatements* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 6
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  %1 = load i1, i1* %0
  br i1 %1, label %label2, label %not_label2
not_label2:
  ; Line 7
  %2 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  store i1 1, i1* %2
  ; Line 8
  %3 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 1
  store i32 1, i32* %3
  br label %label3
label2:
  ; Line 10
  %4 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 1
  store i32 2, i32* %4
  br label %label3
label3:
  ; Line 12
  ret void
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 15
  %1 = alloca %IfStatements
  call void @"IfStatements_<init>()V"(%IfStatements* %1)
  %local.0 = alloca ptr
  store %IfStatements* %1, ptr %local.0
  br label %label0
label0:
  %2 = load %IfStatements*, ptr %local.0
  %instance = bitcast ptr %2 to %IfStatements*
  ; Line 16
  call void @"IfStatements_doSomething()V"(%IfStatements* %instance)
  ; Line 17
  %3 = alloca [6 x i8]
  %4 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 0
  store i8 106, ptr %4
  %5 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 1
  store i8 58, ptr %5
  %6 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 2
  store i8 37, ptr %6
  %7 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 3
  store i8 100, ptr %7
  %8 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 4
  store i8 10, ptr %8
  %9 = getelementptr inbounds [6 x i8], ptr %3, i64 0, i32 5
  store i8 0, ptr %9
  %10 = alloca [1 x i32]
  %11 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i64 0, i32 1
  %12 = load i32, i32* %11
  %13 = getelementptr inbounds [1 x i32], ptr %10, i64 0, i32 0
  store i32 %12, ptr %13
  %14 = getelementptr inbounds [1 x i32], ptr %10, i64 0, i32 0
  %15 = load i32, i32* %14
  %16 = call i32 @printf(ptr %3, i32 %15)
  ; Line 18
  call void @"IfStatements_doSomething()V"(%IfStatements* %instance)
  ; Line 19
  %17 = alloca [6 x i8]
  %18 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 0
  store i8 106, ptr %18
  %19 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 1
  store i8 58, ptr %19
  %20 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 2
  store i8 37, ptr %20
  %21 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 3
  store i8 100, ptr %21
  %22 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 4
  store i8 10, ptr %22
  %23 = getelementptr inbounds [6 x i8], ptr %17, i64 0, i32 5
  store i8 0, ptr %23
  %24 = alloca [1 x i32]
  %25 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i64 0, i32 1
  %26 = load i32, i32* %25
  %27 = getelementptr inbounds [1 x i32], ptr %24, i64 0, i32 0
  store i32 %26, ptr %27
  %28 = getelementptr inbounds [1 x i32], ptr %24, i64 0, i32 0
  %29 = load i32, i32* %28
  %30 = call i32 @printf(ptr %17, i32 %29)
  ; Line 20
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
