from __future__ import annotations


from typing import Optional, Sequence

import json, os

from wraps import AllWraps
from tempfile import NamedTemporaryFile


def main(argv: Optional[Sequence[str]] = None) -> int:
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=str)
    args = parser.parse_args(argv)

    print("\n".join([w.name for w in AllWraps]))

    buffer = json.dumps(
        [e for w in AllWraps for e in w.wrap()],
        indent=2,
    )

    with NamedTemporaryFile("w", delete=False) as file:
        file.write(buffer)
        os.replace(file.name, args.output)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
