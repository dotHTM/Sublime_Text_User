from wrapping import Wrapping


class Wraps:
    """A list of definitions for wrapping rules."""

    # General

    general_new_line = Wrapping(
        prefix="\n",
        suffix="\n",
        keys=["enter"],
        name="General, New line",
        onSelection=True,
    )

    # Web

    html_tags = Wrapping(
        prefix="<",
        suffix=">",
        name="HTML tags",
        onSelection=True,
        scope="text.markdown,source.html",
    )
    markdown_underscore = Wrapping(
        prefix="_",
        suffix="_",
        name="Underscore",
        onSelection=True,
        scope="text.markdown",
    )
    markdown_asterisk = Wrapping(
        prefix="*",
        suffix="*",
        name="Asterisk",
        onSelection=True,
        scope="text.markdown",
    )

    # Perl

    perl_string_concat = Wrapping(
        keys=["."],
        prefix=".",
        suffix=".",
        name="Perl String Concat",
        scope="source.perl",
        onSelection=True,
    )

    # Python

    python_triple_single_quotes = Wrapping(
        prefix="'''",
        suffix="'''",
        keys=["ctrl+alt+'"],
        name="Python Triple Single Quotes",
        scope="source.python",
        onEmpty=True,
    )

    python_triple_double_quotes = Wrapping(
        prefix='"""',
        suffix='"""',
        keys=["ctrl+'"],
        name="Python Triple Double Quotes",
        scope="source.python",
        onEmpty=True,
    )

    python_string_contat = Wrapping(
        prefix="+",
        suffix="+",
        name="Python String Contat",
        scope="source.python",
        onSelection=True,
    )
    python_f_strings_double = Wrapping(
        prefix='f"',
        suffix='"',
        keys=["ctrl+f"],
        name="Python f-strings double",
        scope="source.python",
        onEmpty=True,
    )
    python_f_strings_single = Wrapping(
        prefix="f'",
        suffix="'",
        keys=["ctrl+alt+f"],
        name="Python f-strings single",
        scope="source.python",
        onEmpty=True,
    )

    # AppleScript

    apple_script_concat = Wrapping(
        prefix="&",
        suffix="&",
        name="AppleScript Concat",
        scope="source.applescript",
        onSelection=True,
    )


AllWraps = [
    getattr(Wraps, d) for d in dir(Wraps) if isinstance(getattr(Wraps, d), Wrapping)
]
