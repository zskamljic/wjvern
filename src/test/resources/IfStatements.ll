%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%IfStatements_vtable_type = type { }

%IfStatements = type { %IfStatements_vtable_type*, i32, i1 }

@IfStatements_vtable_data = global %IfStatements_vtable_type {
}

define void @"IfStatements_<init>"(%IfStatements* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 0
  store %IfStatements_vtable_type* @IfStatements_vtable_data, %IfStatements_vtable_type** %0
  ; Line 3
  %1 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  store i1 0, i1* %1
  ret void
}

define void @IfStatements_doSomething(%IfStatements* %this) {
label0:
  ; Line 6
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  %1 = load i1, i1* %0
  br i1 %1, label %label1, label %not_label1
not_label1:
  ; Line 7
  %2 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 2
  store i1 1, i1* %2
  ; Line 8
  %3 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 1
  store i32 1, i32* %3
  br label %label2
label1:
  ; Line 10
  %4 = getelementptr inbounds %IfStatements, %IfStatements* %this, i64 0, i32 1
  store i32 2, i32* %4
  br label %label2
label2:
  ; Line 12
  ret void
}

define i32 @main() {
  ; Line 15
  %1 = alloca %IfStatements
  call void @"IfStatements_<init>"(%IfStatements* %1)
  %instance = bitcast %IfStatements* %1 to %IfStatements*
  br label %label0
label0:
  ; Line 16
  call void @"IfStatements_doSomething"(%IfStatements* %instance)
  ; Line 17
  %2 = alloca [6 x i8]
  %3 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 0
  store i8 106, ptr %3
  %4 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 1
  store i8 58, ptr %4
  %5 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 2
  store i8 37, ptr %5
  %6 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 3
  store i8 100, ptr %6
  %7 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 4
  store i8 10, ptr %7
  %8 = getelementptr inbounds [6 x i8], ptr %2, i64 0, i32 5
  store i8 0, ptr %8
  %9 = alloca [1 x i32]
  %10 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i64 0, i32 1
  %11 = load i32, i32* %10
  %12 = getelementptr inbounds [1 x i32], ptr %9, i64 0, i32 0
  store i32 %11, ptr %12
  %13 = getelementptr inbounds [1 x i32], ptr %9, i64 0, i32 0
  %14 = load i32, i32* %13
  %15 = call i32 @printf(ptr %2, i32 %14)
  ; Line 18
  call void @"IfStatements_doSomething"(%IfStatements* %instance)
  ; Line 19
  %16 = alloca [6 x i8]
  %17 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 0
  store i8 106, ptr %17
  %18 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 1
  store i8 58, ptr %18
  %19 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 2
  store i8 37, ptr %19
  %20 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 3
  store i8 100, ptr %20
  %21 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 4
  store i8 10, ptr %21
  %22 = getelementptr inbounds [6 x i8], ptr %16, i64 0, i32 5
  store i8 0, ptr %22
  %23 = alloca [1 x i32]
  %24 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i64 0, i32 1
  %25 = load i32, i32* %24
  %26 = getelementptr inbounds [1 x i32], ptr %23, i64 0, i32 0
  store i32 %25, ptr %26
  %27 = getelementptr inbounds [1 x i32], ptr %23, i64 0, i32 0
  %28 = load i32, i32* %27
  %29 = call i32 @printf(ptr %16, i32 %28)
  ; Line 20
  ret i32 0
}

declare i32 @printf(ptr, ...) nounwind
