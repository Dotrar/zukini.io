#!/usr/bin/env nu
def main [text] {
  let datestring = ^date +"%Y-%m-%d"
  let file = $"./posts/logs/($datestring)-($text).md"

  $'%{
  title: "($text)",
  description: "",
  topics: ~w(),
}
---

' | save $file
  hx $file
}
