# ResvgTest

A repo to reproduce a `resvg` bug and to determine which published versions have the bug.

To reproduce the bug, just run `mix test`.
When you run it the first time it will download all `resvg` releases since 0.20.0.
Further attempts to tun the tests won't download anything.

It turns out the bug is only fixed from 0.41.0 onwards.
