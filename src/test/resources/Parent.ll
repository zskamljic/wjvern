%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%Parent_vtable_type = type { void(%Parent*)*, void(%Parent*)* }

%Parent = type { %Parent_vtable_type*, i32, i32 }

define void @Parent_parentMethod(%Parent* %this) {
label0:
  ; Line 6
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 1
  store i32 5, i32* %0
  ; Line 7
  ret void
}

define void @Parent_dynamic(%Parent* %this) {
label0:
  ; Line 10
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 2
  store i32 3, i32* %0
  ; Line 11
  ret void
}

@Parent_vtable_data = global %Parent_vtable_type {
  void(%Parent*)* @Parent_parentMethod,
  void(%Parent*)* @Parent_dynamic
}

define void @"Parent_<init>"(%Parent* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Parent, %Parent* %this, i64 0, i32 0
  store %Parent_vtable_type* @Parent_vtable_data, %Parent_vtable_type** %0
  ret void
}
