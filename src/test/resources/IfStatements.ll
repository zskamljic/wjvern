%"java/lang/Object" = type { ptr }
%java_Array = type { i32, ptr }
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
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 0
  store %IfStatements_vtable_type* @IfStatements_vtable_data, %IfStatements_vtable_type** %0
  ; Line 3
  %1 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 2
  store i1 0, i1* %1
  ret void
}

define void @"IfStatements_doSomething()V"(%IfStatements* %this) personality ptr @__gxx_personality_v0 {
label0:
  ; Line 6
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 2
  %1 = load i1, i1* %0
  br i1 %1, label %label2, label %not_label2
not_label2:
  ; Line 7
  %2 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 2
  store i1 1, i1* %2
  ; Line 8
  %3 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 1
  store i32 1, i32* %3
  br label %label3
label2:
  ; Line 10
  %4 = getelementptr inbounds %IfStatements, %IfStatements* %this, i32 0, i32 1
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
  %3 = alloca %java_Array
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  store i32 6, i32* %4
  %5 = alloca i8, i32 6
  %6 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  store ptr %5, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 0
  store i8 106, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 1
  store i8 58, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 2
  store i8 37, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 3
  store i8 100, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 4
  store i8 10, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 5
  store i8 0, ptr %24
  %25 = alloca %java_Array
  %26 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 0
  store i32 1, i32* %26
  %27 = alloca i32, i32 1
  %28 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  store ptr %27, ptr %28
  %29 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i32 0, i32 1
  %30 = load i32, i32* %29
  %31 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  %32 = load ptr, ptr %31
  %33 = getelementptr inbounds i32, ptr %32, i32 0
  store i32 %30, ptr %33
  %34 = getelementptr inbounds %java_Array, ptr %25, i32 0, i32 1
  %35 = load ptr, ptr %34
  %36 = getelementptr inbounds %java_Array, ptr %35, i32 0
  %37 = load i32, i32* %36
  %38 = getelementptr inbounds %java_Array, ptr %3, i32 0, i32 1
  %39 = load ptr, ptr %38
  %40 = call i32 @printf(ptr %39, i32 %37)
  ; Line 18
  call void @"IfStatements_doSomething()V"(%IfStatements* %instance)
  ; Line 19
  %41 = alloca %java_Array
  %42 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 0
  store i32 6, i32* %42
  %43 = alloca i8, i32 6
  %44 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  store ptr %43, ptr %44
  %45 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %46 = load ptr, ptr %45
  %47 = getelementptr inbounds i8, ptr %46, i32 0
  store i8 106, ptr %47
  %48 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %49 = load ptr, ptr %48
  %50 = getelementptr inbounds i8, ptr %49, i32 1
  store i8 58, ptr %50
  %51 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %52 = load ptr, ptr %51
  %53 = getelementptr inbounds i8, ptr %52, i32 2
  store i8 37, ptr %53
  %54 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %55 = load ptr, ptr %54
  %56 = getelementptr inbounds i8, ptr %55, i32 3
  store i8 100, ptr %56
  %57 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %58 = load ptr, ptr %57
  %59 = getelementptr inbounds i8, ptr %58, i32 4
  store i8 10, ptr %59
  %60 = getelementptr inbounds %java_Array, %java_Array* %41, i32 0, i32 1
  %61 = load ptr, ptr %60
  %62 = getelementptr inbounds i8, ptr %61, i32 5
  store i8 0, ptr %62
  %63 = alloca %java_Array
  %64 = getelementptr inbounds %java_Array, %java_Array* %63, i32 0, i32 0
  store i32 1, i32* %64
  %65 = alloca i32, i32 1
  %66 = getelementptr inbounds %java_Array, %java_Array* %63, i32 0, i32 1
  store ptr %65, ptr %66
  %67 = getelementptr inbounds %IfStatements, %IfStatements* %instance, i32 0, i32 1
  %68 = load i32, i32* %67
  %69 = getelementptr inbounds %java_Array, %java_Array* %63, i32 0, i32 1
  %70 = load ptr, ptr %69
  %71 = getelementptr inbounds i32, ptr %70, i32 0
  store i32 %68, ptr %71
  %72 = getelementptr inbounds %java_Array, ptr %63, i32 0, i32 1
  %73 = load ptr, ptr %72
  %74 = getelementptr inbounds %java_Array, ptr %73, i32 0
  %75 = load i32, i32* %74
  %76 = getelementptr inbounds %java_Array, ptr %41, i32 0, i32 1
  %77 = load ptr, ptr %76
  %78 = call i32 @printf(ptr %77, i32 %75)
  ; Line 20
  ret i32 0
}

declare i32 @printf(%java_Array, ...) nounwind
