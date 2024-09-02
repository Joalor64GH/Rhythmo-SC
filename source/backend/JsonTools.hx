package backend;

#if FUTURE_POLYMOD
class JsonTools extends polymod.format.ParseRules.JSONParseFormat {
	override private function _mergeObjects(a:Dynamic, b:Dynamic, signatureSoFar:String = ''):Dynamic {
		if (Std.isOfType(a, Array) && Std.isOfType(b, Array)) {
			var c:Array<Dynamic> = [];

			var d:Array<Dynamic> = a;
			var e:Array<Dynamic> = b;

			for (x in d) {
				c.push(x);
			}

			for (x in e) {
				c.push(x);
			}

			return c;
		} else if (!Std.isOfType(a, Array) && !Std.isOfType(b, Array)) {
			var aPrimitive = isPrimitive(a);
			var bPrimitive = isPrimitive(b);

			if (aPrimitive && bPrimitive) {
				return b;
			} else if (aPrimitive != bPrimitive) {
				return a;
			} else {
				for (field in Reflect.fields(b)) {
					if (Reflect.hasField(a, field)) {
						var aValue = Reflect.field(a, field);
						var bValue = Reflect.field(b, field);
						var mergedValue = copyVal(_mergeObjects(aValue, bValue, '$signatureSoFar.$field'));

						Reflect.setField(a, field, mergedValue);
					} else {
						Reflect.setField(a, field, Reflect.field(b, field));
					}
				}
			}
		} else {
			var aArr = Std.isOfType(a, Array) ? 'array' : 'object';
			var bArr = Std.isOfType(b, Array) ? 'array' : 'object';

			Polymod.warning(MERGE, "JSON can't merge @ (" + signatureSoFar + ") because base is (" + aArr + ") but payload is (" + bArr + ')');
		}

		return a;
	}
}
#end