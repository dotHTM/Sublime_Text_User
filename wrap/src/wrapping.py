import json
import re
from typing import NamedTuple


regexSpecialChars = lambda inp: re.sub(r"([\.\{\[])", r"\\\1", inp)


class Wrapping(NamedTuple):
    """Object for building templated wraping rules."""

    prefix: str
    suffix: str
    name: str
    keys: list[str] = []

    scope: str = "source,text"

    onEmpty: bool = False
    onSelection: bool = False
    enterExit: bool = False

    @property
    def regexPrefix(self) -> str:
        return regexSpecialChars(self.prefix)

    @property
    def regexSuffix(self) -> str:
        return regexSpecialChars(self.suffix)

    @property
    def simple(self) -> bool:
        return 1 == len(self.prefix) and 1 == len(self.suffix)

    @property
    def same(self) -> bool:
        return self.prefix == self.suffix

    @property
    def uniqfix(self) -> str:
        if self.same:
            return self.prefix
        return self.prefix + self.suffix

    @property
    def __keys(self) -> list[str]:
        if 0 < len(self.keys):
            return self.keys
        assert 1 == len(
            self.prefix
        ), f"{self.name}: Got unexpected key from prefix '{self.prefix}'."
        return [self.prefix]

    @property
    def __name(self) -> str:
        if self.name:
            return f"Wrap '{self.name}'"
        return f"Wrap ({self.prefix}, {self.suffix})"

    def template_hasSelection(self) -> dict:
        return {
            "comment": f"{self.__name}, has selection",
            "keys": self.__keys,
            "command": "insert_snippet",
            "args": {"contents": self.prefix + "${0:$SELECTION}" + self.suffix},
            "context": [
                {
                    "key": "setting.auto_match_enabled",
                    "operator": "equal",
                    "operand": True,
                },
                {
                    "key": "selection_empty",
                    "operator": "equal",
                    "operand": False,
                    "match_all": True,
                },
            ],
        }

    def template_empty(self) -> dict:
        return {
            "comment": f"{self.__name}, selection_empty, not mid-word",
            "keys": self.__keys,
            "command": "insert_snippet",
            "args": {"contents": self.prefix + "$0" + self.suffix},
            "context": [
                {
                    "key": "setting.auto_match_enabled",
                    "operator": "equal",
                    "operand": True,
                },
                {
                    "key": "selection_empty",
                    "operator": "equal",
                    "operand": True,
                    "match_all": True,
                },
                {
                    "key": "following_text",
                    "operator": "regex_contains",
                    "operand": "^(?:\t| |\\)|]|\\}|>|$)",
                    "match_all": True,
                },
                {
                    "key": "preceding_text",
                    "operator": "not_regex_contains",
                    "operand": "[a-zA-Z0-9]$",
                    "match_all": True,
                },
                # {
                #     "key": "eol_selector",
                #     "operator": "not_equal",
                #     "operand": "string.quoted.single - punctuation.definition.string.end",
                #     "match_all": True,
                # },
            ],
        }

    def template_del_LR(self) -> dict:
        return {
            "comment": f"{self.__name}, remove 1 left and 1 right",
            "keys": self.__keys,
            "command": "run_macro_file",
            "args": {"file": "res://Packages/Default/Delete Left Right.sublime-macro"},
            "context": [
                {
                    "key": "setting.auto_match_enabled",
                    "operator": "equal",
                    "operand": True,
                },
                {
                    "key": "selection_empty",
                    "operator": "equal",
                    "operand": True,
                    "match_all": True,
                },
                {
                    "key": "preceding_text",
                    "operator": "regex_contains",
                    "operand": f"{self.regexPrefix}$",
                    "match_all": True,
                },
                {
                    "key": "following_text",
                    "operator": "regex_contains",
                    "operand": f"^{self.regexSuffix}",
                    "match_all": True,
                },
                {
                    "key": "selector",
                    "operator": "not_equal",
                    "operand": "punctuation.definition.string.begin",
                    "match_all": True,
                },
                {
                    "key": "eol_selector",
                    "operator": "not_equal",
                    "operand": "string.quoted.single - punctuation.definition.string.end",
                    "match_all": True,
                },
            ],
        }

    def template_enterExit(self) -> dict:
        return {
            "comment": f"{self.__name}, enter or exit group",
            "keys": self.__keys,
            "command": "move",
            "args": {"by": "characters", "forward": True},
            "context": [
                {
                    "key": "setting.auto_match_enabled",
                    "operator": "equal",
                    "operand": True,
                },
                {
                    "key": "selection_empty",
                    "operator": "equal",
                    "operand": True,
                    "match_all": True,
                },
                {
                    "key": "following_text",
                    "operator": "regex_contains",
                    "operand": f"^({self.prefix}|{self.suffix})",
                    "match_all": True,
                },
                {
                    "key": "selector",
                    "operator": "not_equal",
                    "operand": "punctuation.definition.string.begin",
                    "match_all": True,
                },
                {
                    "key": "eol_selector",
                    "operator": "not_equal",
                    "operand": "string.quoted.single - punctuation.definition.string.end",
                    "match_all": True,
                },
            ],
        }

    def wrap(self) -> list[dict]:
        ret: list[dict] = []
        if self.onEmpty:
            ret.append(self.template_empty())
        if self.onSelection:
            ret.append(self.template_hasSelection())
        if self.simple:
            ret.append(self.template_del_LR())
        if self.enterExit:
            ret.append(self.template_enterExit())

        return ret

    def json(self) -> str:
        return json.dumps(self.wrap(), indent=2)
