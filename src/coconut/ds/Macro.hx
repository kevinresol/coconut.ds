package coconut.ds;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.BuildCache;
using tink.MacroApi;

class Macro {
	public static function buildOptional() {
		return BuildCache.getType('coconut.ds.Optional', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			var def = macro class $name {};
			function add(c:TypeDefinition) def.fields = def.fields.concat(c.fields);
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) {
						var fname = field.name;
						var ct = field.type.toComplex();
						if(field.type.match(TAnonymous(_))) ct = macro:coconut.ds.Optional<$ct>;
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
		return BuildCache.getType('coconut.ds.Editable', function(ctx) {
			var name = ctx.name;
			var ct = ctx.type.toComplex();
			var def = macro class $name implements coconut.data.Model {
				@:constant var loader:Void->tink.core.Promise<$ct>;
				@:constant var updater:coconut.ds.Optional<$ct>->tink.core.Promise<tink.core.Noise>;
				public function refresh() return loader().next(set);
				public function update(v:coconut.ds.Optional<$ct>) return updater(v).next(function(_) return setOptional(v));
			}
			
			function add(c:TypeDefinition) def.fields = def.fields.concat(c.fields);
			
			var setExprs = [];
			var setOptionalExprs = [];
			
			switch ctx.type.reduce() {
				case TAnonymous(_.get() => {fields: fields}):
					for(field in fields) {
						var fname = field.name;
						var pname = '_$fname';
						var ct = field.type.toComplex();
						setExprs.push(macro $i{pname} = v.$fname);
						setOptionalExprs.push(macro switch v.$fname {
							case Some(v): $i{pname} = v;
							case None: // do nothing
						});
						
						add(macro class {
							@:computed var $fname:$ct = $i{pname};
							@:editable private var $pname:$ct = @byDefault null;
						});
					}
				default:
					ctx.pos.error('Only supports anonymous structures');
			}
			
			add(macro class {
				function set(v:$ct) {
					$b{setExprs};
					return tink.core.Noise.Noise.Noise;
				}
				function setOptional(v:coconut.ds.Optional<$ct>) {
					$b{setOptionalExprs};
					return tink.core.Noise.Noise.Noise;
				}
			});
			
			def.pack = ['coconut', 'ds'];
			trace(new haxe.macro.Printer().printTypeDefinition(def));
			return def;
			
			
		});
	}
}