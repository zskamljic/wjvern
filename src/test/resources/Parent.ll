%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%Parent_vtable_type = type { void(%Parent*)* }

%Parent = type { %Parent_vtable_type*, i32 }

define void @Parent_parentMethod(%Parent* %this) {
label0:
  ; Line 5
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 1
  store i32 5, i32* %0
  ; Line 6
  ret void
}

@Parent_vtable_data = global %Parent_vtable_type {
  void(%Parent*)* @Parent_parentMethod
}

define void @"Parent_<init>"(%Parent* %this) {
  %1 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %1
  br label %label0
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ret void
}
