package coconut.ds;

using tink.CoreApi;

@:genericBuild(coconut.ds.Macro.buildEditable())
class Editable<Id, Data> {}

@:genericBuild(coconut.ds.Macro.buildPatcher())
class Patcher<Data> {}