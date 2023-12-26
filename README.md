# Computed & Drift

This repo is a fork of the [upstream Drift repo](https://github.com/simolus3/drift) and hosts Drift samples re-written using [Computed](https://github.com/mstniy/computed.dart) reactivity.

## The todo app

[The todo app](https://github.com/mstniy/computed_drift/tree/computed/examples/app) is re-written to use Computed reactivity instead of Riverpod.  
The commit history demonstrates how an existing app can be gradually converted to Computed reactivity, and how it can coexist with other state management solutions.

Note that the final version has no dependency on Riverpod or any other state manager except for Drift and Computed, doesn't define custom `ValueNotifier` or `Listenable`s, has no ad-hoc mutable state, never uses `addListener` and has no stateful widgets.
