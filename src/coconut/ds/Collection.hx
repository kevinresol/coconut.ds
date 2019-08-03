package coconut.ds;

import tink.pure.List;
import tink.state.Promised;
import coconut.ds.Dict;

using tink.CoreApi;

typedef Init<Key, Data, Item> = {
	fetch:Void->Promise<List<Data>>,
	extractKey:Data->Key,
	createItem:Key->Data->Item,
	updateItem:Item->Data->Void,
	?cache:Option<List<Item>>,
}

@:multiType(@:followWithAbstracts K)
abstract Collection<K, Data, Item>(ICollection<K, Data, Item>) from ICollection<K, Data, Item> {
	public var list(get, never):Promised<List<Item>>;
	public var map(get, never):Dict<K, Item>;
	
	public function new(init:Init<K, Data, Item>);
	
	inline function get_list()
		return this.list;
		
	inline function get_map()
		return this.map;
		
	public inline function refresh()
		this.refresh();
		
	public inline function get(key:K):Item
		return this.map.get(key);
	
	@:to inline function toIntCollection<K:Int, Data, Item>(init):IntCollection<Data, Item>
		return new IntCollection<Data, Item>(init);
	
	@:to inline function toStringCollection<K:String, Data, Item>(init):StringCollection<Data, Item>
		return new StringCollection<Data, Item>(init);
	
	@:to inline function toEnumValueCollection<K:EnumValue, Data, Item>(init):EnumValueCollection<Data, Item>
		return new EnumValueCollection<Data, Item>(init);
	
	@:from static inline function fromIntCollection<Data, Item>(collection:IntCollection<Data, Item>):Collection<Int, Data, Item>
		return collection;
	
	@:from static inline function fromStringCollection<Data, Item>(collection:StringCollection<Data, Item>):Collection<String, Data, Item>
		return collection;
	
	@:from static inline function fromEnumValueCollection<Data, Item>(collection:EnumValueCollection<Data, Item>):Collection<EnumValue, Data, Item>
		return collection;
}

interface ICollection<K, Data, Item> {
	var list(get, never):Promised<List<Item>>;
	var map(get, never):Dict<K, Item>;
	function refresh(?cache:Option<List<Item>> = @byDefault None):Void;
}

class IntCollection<Data, Item> implements coconut.data.Model implements ICollection<Int, Data, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<Data>>;
	@:constant var createItem:Int->Data->Item;
	@:constant var updateItem:Item->Data->Void;
	@:constant var extractKey:Data->Int;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<Int, Item> = new Dict(createItem.bind(_, null));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class StringCollection<Data, Item> implements coconut.data.Model implements ICollection<String, Data, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<Data>>;
	@:constant var createItem:String->Data->Item;
	@:constant var updateItem:Item->Data->Void;
	@:constant var extractKey:Data->String;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<String, Item> = new Dict(createItem.bind(_, null));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}

class EnumValueCollection<Data, Item> implements coconut.data.Model implements ICollection<EnumValue, Data, Item> {
	@:editable private var revision:Int = 0;
	@:constant var fetch:Void->Promise<List<Data>>;
	@:constant var createItem:EnumValue->Data->Item;
	@:constant var updateItem:Item->Data->Void;
	@:constant var extractKey:Data->EnumValue;
	@:editable private var cache:Option<List<Item>> = @byDefault None;
	@:loaded var list:List<Item> = {
		revision;
		switch cache {
			case None:
				fetch().next(function(list) return list.map(function(data) {
					var item = map.get(extractKey(data));
					updateItem(item, data);
					return item;
				}));
			case Some(v):
				v;
		}
	}
	@:constant var map:Dict<EnumValue, Item> = new Dict(createItem.bind(_, null));
	
	public function refresh(cache = None) {
		this.cache = cache;
		revision++;
	}
}