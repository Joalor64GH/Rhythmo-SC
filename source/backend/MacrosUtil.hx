package backend;

import sys.io.Process;

class MacrosUtil {
	public static macro function get_commit_id():haxe.macro.Expr.ExprOf<String> {
		try {
			var daProcess = new Process('git', ['log', '--format=%h', '-n', '1']);
			daProcess.exitCode(true);
			return macro $v{daProcess.stdout.readLine()};
		} catch (e) {}
		return macro $v{"-"};
	}
}