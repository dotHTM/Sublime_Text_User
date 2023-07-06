from __future__ import annotations

from typing import Optional, Sequence

import json

from wraps import Wraps


def main(argv: Optional[Sequence[str]] = None) -> int:
    import argparse

    parser = argparse.ArgumentParser()
    # parser.add_argument()
    args = parser.parse_args(argv)

    print(
        json.dumps(
            # Wraps.python_triple_double_quotes.wrap(),
            [e for w in Wraps.MainWraps for e in w.wrap()],
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
