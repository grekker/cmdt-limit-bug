public with sharing class Demo {

	public static void noLimit() {
		dump([SELECT MasterLabel, (SELECT MasterLabel FROM Bars__r) FROM Foo__mdt ORDER BY MasterLabel]);
	}

	public static void withLimit(Integer theLimit) {
		dump([SELECT MasterLabel, (SELECT MasterLabel FROM Bars__r LIMIT :theLimit) FROM Foo__mdt ORDER BY MasterLabel]);
	}

	private static void dump(List<Foo__mdt> foos) {
		for(Foo__mdt foo : foos) {
			String message = 'Foo: ' + foo.MasterLabel + '\n';
			for(Bar__mdt bar : foo.Bars__r) {
				message += '\tChild Bar: ' + bar.MasterLabel + '\n';
			}
			System.debug(LoggingLevel.WARN, message);
		}
	}
}