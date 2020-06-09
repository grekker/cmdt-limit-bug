# cMDT Relationship Query Bug

This repository is a bug repro for Salesforce Custom Metadata Types when using relationship queries and the LIMIT clause.

### Undesirable Behavior

This query should limit the children per parent.

`SELECT MasterLabel, (SELECT MasterLabel FROM Bars__r LIMIT 1) FROM Foo__mdt`

However, it actually limits the entire set of children, so that one parent has a single child and all other parents have no children.

## Reproducing

Defined in this repo are two custom metadata types Foo and Bar, with a relationship from Bar to Foo. There are a number of existing cMDT records in both types to facilitate showing the bug.

A single Apex class exists called Demo that can be called from anonymous Apex to demonstrate the bug. Here is the class:

```
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
```

Here are some sample outputs:

`Demo.noLimit();`

```
15:00:07.29 (47299861)|USER_DEBUG|[17]|WARN|Foo: Foo1
	Child Bar: Foo1Bar4
	Child Bar: Foo1Bar2
	Child Bar: Foo1Bar3
	Child Bar: Foo1Bar1

15:00:07.29 (48652105)|USER_DEBUG|[17]|WARN|Foo: Foo2
	Child Bar: Foo2Bar2
	Child Bar: Foo2Bar1

15:00:07.29 (50219163)|USER_DEBUG|[17]|WARN|Foo: Foo3
	Child Bar: Foo2Bar3
	Child Bar: Foo3Bar1
	Child Bar: Foo3Bar2
```

`Demo.withLimit(20);`

```
15:00:40.53 (86781549)|USER_DEBUG|[17]|WARN|Foo: Foo1
	Child Bar: Foo1Bar4
	Child Bar: Foo1Bar2
	Child Bar: Foo1Bar3
	Child Bar: Foo1Bar1

15:00:40.53 (88958956)|USER_DEBUG|[17]|WARN|Foo: Foo2
	Child Bar: Foo2Bar2
	Child Bar: Foo2Bar1

15:00:40.53 (91248572)|USER_DEBUG|[17]|WARN|Foo: Foo3
	Child Bar: Foo2Bar3
	Child Bar: Foo3Bar1
	Child Bar: Foo3Bar2
```

`Demo.withLimit(5);`

```
15:01:06.30 (49240116)|USER_DEBUG|[17]|WARN|Foo: Foo1
	Child Bar: Foo1Bar4
	Child Bar: Foo1Bar2
	Child Bar: Foo1Bar3
	Child Bar: Foo1Bar1

15:01:06.30 (50139460)|USER_DEBUG|[17]|WARN|Foo: Foo2
	Child Bar: Foo2Bar2

15:01:06.30 (50662405)|USER_DEBUG|[17]|WARN|Foo: Foo3
```

`Demo.withLimit(2);`

```
15:01:31.28 (44578740)|USER_DEBUG|[17]|WARN|Foo: Foo1
	Child Bar: Foo1Bar4
	Child Bar: Foo1Bar2

15:01:31.28 (45043084)|USER_DEBUG|[17]|WARN|Foo: Foo2

15:01:31.28 (45425628)|USER_DEBUG|[17]|WARN|Foo: Foo3
```

`Demo.withLimit(1);`

```
15:01:54.35 (49885876)|USER_DEBUG|[17]|WARN|Foo: Foo1
	Child Bar: Foo1Bar4

15:01:54.35 (50350946)|USER_DEBUG|[17]|WARN|Foo: Foo2

15:01:54.35 (50759944)|USER_DEBUG|[17]|WARN|Foo: Foo3
```