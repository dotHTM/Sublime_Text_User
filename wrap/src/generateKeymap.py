from __future__ import annotations


from typing import Optional, Sequence

import json

from wraps import AllWraps


def main(argv: Optional[Sequence[str]] = None) -> int:
    import argparse

    parser = argparse.ArgumentParser()
    # parser.add_argument()
    args = parser.parse_args(argv)

    print(
        json.dumps(
            [e for w in AllWraps for e in w.wrap()],
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
