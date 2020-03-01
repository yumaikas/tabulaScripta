import webConfig
import htmlgen, markdown, strformat

proc css*(): string =
  # TODO: make this select from a list of themes, or pull from the database
  var back_color = "#191e2a"
  var fore_color = "#21EF9F"
  var link_color = "aqua"
  var visted_color = "darkcyan"
  if THEME == "AQUA":
    discard
  elif THEME == "AUTUMN":
    back_color = "#2a2319"
    fore_color = "#EFC121"
    link_color = "F0FF00"
    visted_color = "#a5622a"
  elif THEME == "AMBER":
    back_color = "black"
    fore_color = "yellow"
    link_color = "yellow"
    visted_color = "#f1ad14"

  # Right now, the implicit default theme is AQUA, if we don't recognize the current theme.

  return style(&"""
body {{
  max-width: 800px;
  width: 90%;
}}
body,input,textarea {{
  font-family: Iosevka, monospace;
  background: {back_color};
  color: {fore_color};
}}
table {{
  border-collapse: collapse;
}}
table input {{
  border: none;
}}
tr {{
  min-height: 20px;
}}
td {{
  margin: 5px;
  border: 1px solid {fore_color};
  min-width: 2em;
  min-height: 1em;
}}
a {{ color: {link_color}; }}
a:visited {{ color: {visted_color}; }}
""")

proc pageBase*(inner: string, showHeader: bool = true): string =
  return "<!DOCTYPE html>" & html(
    head(
      meta(charset="utf-8"),
      meta(name="viewport", content="width=device-width, initial-scale=1.0")
    ),
    body(
      css(),
      h2("Tabula Scripta"),
      script(src="/gotoB.min.js"),
      # It is expected that this will mostly be JS
      inner
    )
  )

