/**
 * @ Author: 4mbr0s3 2
 * @ Create Time: 2021-08-08 16:18:02
 * @ Modified by: 4mbr0s3 2
 * @ Modified time: 2021-12-26 20:58:05
 */

package false_paradise.note_mods;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.math.Vector4;
import schmovin.SchmovinPlayfield;
import schmovin.note_mods.NoteModBase;

using schmovin.SchmovinUtil;

class TimeVector extends Vector4
{
	public var startDist = 0.0;
	public var endDist = 0.0;
	public var next:TimeVector;
}

class NoteModArrowShape extends NoteModBase
{
	var _path:List<TimeVector>;
	var _pathDistance:Float = 0;

	static inline var SCALE = 200;

	function LoadPath():List<TimeVector>
	{
		var file = CoolUtil.coolTextFile('mod:mod_assets/FalseParadiseMod/weeks/arrowpaths/arrowpath1.csv');
		var path = new List<TimeVector>();
		for (line in file)
		{
			var coords = line.split(';');
			var vec = new TimeVector(Std.parseFloat(coords[0]), Std.parseFloat(coords[1]), Std.parseFloat(coords[2]), Std.parseFloat(coords[3]));
			vec.scaleBy(SCALE);
			path.add(vec);
		}
		_pathDistance = CalculatePathDistances(path);
		return path;
	}

	function CalculatePathDistances(path:List<TimeVector>)
	{
		var iterator = path.iterator();
		var last = iterator.next();
		last.startDist = 0;
		var dist = 0.0;
		while (iterator.hasNext())
		{
			var current = iterator.next();
			var differential = current.subtract(last);
			dist += differential.length;
			current.startDist = dist;
			last.next = current;
			last.endDist = current.startDist;
			last = current;
		}
		return dist;
	}

	function GetPointAlongPath(distance:Float):Null<Vector4>
	{
		for (vec in _path)
		{
			if (FlxMath.inBounds(distance, vec.startDist, vec.endDist) && vec.next != null)
			{
				var ratio = (distance - vec.startDist) / vec.next.subtract(vec).length;
				return SchmovinUtil.vec4Lerp(vec, vec.next, ratio);
			}
		}
		return _path.first();
	}

	override function executePath(currentBeat:Float, strumTime:Float, column:Int, player:Int, pos:Vector4, playfield:SchmovinPlayfield):Vector4
	{
		if (_path == null)
			_path = LoadPath();

		var path = GetPointAlongPath(strumTime / -1500.0 * _pathDistance);

		return SchmovinUtil.vec4Lerp(pos,
			path.add(new Vector4(FlxG.width / 2, FlxG.height / 2 + 280, (column % 4) * getOtherPercent('arrowshapeoffset', playfield) + pos.z)),
			getPercent(playfield));
	}
}
