package coconut.ds;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;
using tink.MacroApi;

class Macro {
	public static function buildPatch() {
		return BuildCache.getType('coconut.ds.Patch', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			var def = macro class $name {};
			function add(c:TypeDefinition) def.fields = def.fields.concat(c.fields);
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) if(field.meta.has(':patchable')) {
						var fname = field.name;
						var ct = field.type.toComplex();
						if(field.type.reduce().match(TAnonymous(_))) ct = macro:coconut.ds.Patch<$ct>;
						add(macro class {
							var $fname:haxe.ds.Option<$ct>;
						});
					}
				default:
					ctx.pos.error('Only supports anonymous structures');
			}
			
			def.pack = ['coconut', 'ds'];
			def.kind = TDStructure;
			return def;
		});
	}
	
	public static function buildEditable() {
		return BuildCache.getType2('coconut.ds.Editable', function(ctx) {
			var name = ctx.name;
			var idCt = ctx.type.toComplex();
			var dataCt = ctx.type2.toComplex();
			var def = macro class $name implements coconut.data.Model {
				@:constant var id:$idCt;
				@:loaded var data:$dataCt = cache == null ? loader(id).next(function(data) {cache = data; return data;}) : cache;
				@:editable private var cache:$dataCt = @byDefault null;
				@:constant var loader:$idCt->tink.core.Promise<$dataCt>;
				@:constant var updater:$idCt->coconut.ds.Patch<$dataCt>->tink.core.Promise<tink.core.Noise>;
				
				public function refresh() 
					return cache = null;
					
				@:transition function update(patch:coconut.ds.Patch<$dataCt>)
					return updater(id, patch).next(function(_) return {cache: new coconut.ds.Editable.Patcher<$dataCt>().patch(cache, patch)});
			}
			def.pack = ['coconut', 'ds'];
			return def;
		});
	}
	
	public static function buildPatcher() {
		return BuildCache.getType('coconut.ds.Patcher', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			
			var objFields = [];
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) if(field.meta.has(':patchable')) {
						var fname = field.name;
						var ct = field.type.toComplex();
						
						objFields.push({
							field: fname,
							expr: macro switch patch.$fname {
								case Some(v):
									${switch field.type.reduce() {
										case TAnonymous(_): macro new coconut.ds.Editable.Patcher<$ct>().patch(data.$fname, v);
										case _: macro v;
									}}
								case None:
									data.$fname;
							}
						});
					}
				default:
					ctx.pos.error('Only supports anonymous structures');
			}
			
			var body = macro return ${EObjectDecl(objFields).at()};
			
			var def = macro class $name {
				public function new() {}
				public function patch(data:$ct, patch:coconut.ds.Patch<$ct>) $body;
			}
			
			def.pack = ['coconut', 'ds'];
			return def;
		});
	}
}