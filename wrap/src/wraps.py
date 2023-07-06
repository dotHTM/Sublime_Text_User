from wrapping import Wrapping


class Wraps:
    """A list of definitions for wrapping rules."""

    # Web

    html_tags = Wrapping(
        prefix="<",
        suffix=">",
        name="HTML tags",
        wrapOnly=True,
        scope="text.markdown,source.html",
    )
    markdown_underscore = Wrapping(
        prefix="_",
        suffix="_",
        name="Underscore",
        wrapOnly=True,
        scope="text.markdown",
    )
    markdown_asterisk = Wrapping(
        prefix="*",
        suffix="*",
        name="Asterisk",
        wrapOnly=True,
        scope="text.markdown",
    )

    # Perl

    perl_string_concat = Wrapping(
        keys=["."],
        prefix=".",
        suffix=".",
        name="Perl String Concat",
        scope="source.perl",
        wrapOnly=True,
    )

    # Python

    python_triple_single_quotes = Wrapping(
        prefix="'''",
        suffix="'''",
        keys=["ctrl+alt+'"],
        name="Python Triple Single Quotes",
        scope="source.python",
    )

    python_triple_double_quotes = Wrapping(
        prefix='"""',
        suffix='"""',
        keys=["ctrl+'"],
        name="Python Triple Double Quotes",
        scope="source.python",
    )

    python_string_contat = Wrapping(
        prefix="+",
        suffix="+",
        name="Python String Contat",
        scope="source.python",
        wrapOnly=True,
    )
    python_f_strings_double = Wrapping(
        prefix='f"',
        suffix='"',
        keys=["ctrl+f"],
        name="Python f-strings double",
        scope="source.python",
    )
    python_f_strings_single = Wrapping(
        prefix="f'",
        suffix="'",
        keys=["ctrl+alt+f"],
        name="Python f-strings single",
        scope="source.python",
    )

    # AppleScript

    apple_script_concat = Wrapping(
        prefix="&",
        suffix="&",
        name="AppleScript Concat",
        scope="source.applescript",
        wrapOnly=True,
    )

    MainWraps = [
        html_tags,
        markdown_underscore,
        markdown_asterisk,
        perl_string_concat,
        python_triple_single_quotes,
        python_triple_double_quotes,
        python_string_contat,
        python_f_strings_double,
        python_f_strings_single,
        apple_script_concat,
    ]
